#!/bin/bash
################################################################################
#
# init
# ----------------
# Initialize the dotfiles on a Ubuntu system
#
# @author Nicholas Wilde, 0xb299a622
# @date 22 Apr 2025
# @version 0.1.1
#
################################################################################

set -e
set -o pipefail

bold=$(tput bold)
normal=$(tput sgr0)
blue=$(tput setaf 4)
default=$(tput setaf 9)
white=$(tput setaf 7)

DEFAULT_ORG_NAME="nicholaswilde"
DEFAULT_GIT_DIR="${HOME}/git/${DEFAULT_ORG_NAME}"
DEFAULT_EMAIL_ADDRESS="ncwilde43@gmail.com"
DEFAULT_REPO_NAME="dotfiles2"
DEFAULT_REPO_URL="git@github.com:${DEFAULT_ORG_NAME}/${DEFAULT_REPO_NAME}.git"
DEFAULT_REPO_DIR="${DEFAULT_GIT_DIR}/${DEFAULT_REPO_NAME}"
DEFAULT_GPG_LPASS_ID="gpg"
DEFAULT_GPG_LPASS_ATTACH_ID="att-8017296795546256342-55097"
DEFAULT_SSH_LPASS_ID="ssh"
DEFAULT_SSH_LPASS_ATTACH_ID="att-4322045537695550419-20689"

readonly bold
readonly normal
readonly blue
readonly default
readonly white

function print_text(){
  echo "${blue}==> ${white}${bold}${1}${normal}${default}"
}

# Check if variable is null
# Returns true if empty
function is_null(){
  [ -z "${1}" ]
}

# Check if directory exists
function dir_exists(){
  [ -d "${1}" ]
}

# Check if command exists
function command_exists(){
  command -v "${1}" &> /dev/null
}

# Check if variable is set
# Returns false if empty
function is_set(){
  [ -n "${1}" ]
}

function set_vars(){
  ! is_set "${ORG_NAME}" && ORG_NAME="$DEFAULT_ORG_NAME"
  ! is_set "${GIT_DIR}" && GIT_DIR="$DEFAULT_GIT_DIR"
  ! is_set "${EMAIL_ADDRESS}" && EMAIL_ADDRESS="$DEFAULT_EMAIL_ADDRESS"
  ! is_set "${REPO_NAME}" && REPO_NAME="$DEFAULT_REPO_NAME"
  ! is_set "${REPO_URL}" && REPO_URL="$DEFAULT_REPO_URL"
  ! is_set "${REPO_DIR}" && REPO_DIR="$DEFAULT_REPO_DIR"
  ! is_set "${GPG_LPASS_ID}" && GPG_LPASS_ID="$DEFAULT_GPG_LPASS_ID"
  ! is_set "${GPG_LPASS_ATTACH_ID}" && GPG_LPASS_ATTACH_ID="$DEFAULT_GPG_LPASS_ATTACH_ID"
  ! is_set "${SSH_LPASS_ID}" && SSH_LPASS_ID="$DEFAULT_SSH_LPASS_ID"
  ! is_set "${SSH_LPASS_ATTACH_ID}" && SSH_LPASS_ATTACH_ID="$DEFAULT_SSH_LPASS_ATTACH_ID"
}

function prevent_subshell(){
  if [[ $_ != "$0" ]]; then
    echo "Script is being sourced"
  else
    echo "Script is a subshell - please run the script by invoking . script.sh command"
    exit 1
  fi
}

function make_git_dir(){
  print_text "Make git directory"
  ! dir_exists "${GIT_DIR}" && mkdir -p "${GIT_DIR}"
  cd "${GIT_DIR}" || exit 1
}

function clone_repo(){
  print_text "Clone repo"
  if ! dir_exists "${REPO_DIR}"; then
    git clone "${REPO_URL}" "${REPO_DIR}"
  fi
  cd "${REPO_DIR}" || exit 1
}

function install_brew(){
  print_text "Install brew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # shellcheck disable=SC2016
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "${HOME}/.profile"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  sudo apt-get update
  sudo apt-get install -y build-essential
  # shellcheck source=/dev/null
  source "${HOME}/.profile"
}

function install_lastpass(){
  print_text "Install Lastpass"
  brew install lastpass-cli
  # shellcheck source=/dev/null
  source "${HOME}/.profile"
  LPASS_DISABLE_PINENTRY=1 lpass login --trust "${EMAIL_ADDRESS}"
}

function setup_ssh(){
  print_text "Setup SSH"
  if ! command_exists ssh-import-id-gh; then
    sudo apt-get install -y ssh-import-id
  fi
  if ! dir_exists ~/.ssh; then
    mkdir ~/.ssh
  fi
  curl "https://github.com/${ORG_NAME}.keys" -o ~/.ssh/id_rsa.pub
  chmod 644 ~/.ssh/id_rsa.pub
  lpass show "${SSH_LPASS_ID}" --attach="${SSH_LPASS_ATTACH_ID}" -q > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
  chmod 0700 ~/.ssh
  ssh-import-id-gh "${ORG_NAME}"
}

function setup_gpg(){
  print_text "Setup GPG"
  lpass show "${GPG_LPASS_ID}" --attach="${GPG_LPASS_ATTACH_ID}" -q | gpg --import
  gpg --refresh-keys --keyserver keyserver.ubuntu.com
}

function install_task(){
  print_text "Install task"
  if command_exists task; then
    echo "task is already installed"
    return 0
  fi
  brew install go-task/tap/go-task 
}

function end_script(){
  print_text "dotfiles init complete"
  echo "- Source the profile file to gain access to brew commands:"
  echo "    source ~/.profile"
  echo "- Change to dotfiles repo directory and install dotfiles"
  echo "    cd ${REPO_DIR}"
  echo "    task dotfiles"
}

function main(){
  set_vars
  prevent_subshell
  make_git_dir
  install_brew
  install_lastpass
  setup_ssh
  setup_gpg
  install_task
  clone_repo
  end_script
}

main "$@"
