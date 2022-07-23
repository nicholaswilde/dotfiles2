#!/bin/bash
################################################################################
#
# init
# ----------------
# Initialize the dotfiles on a Ubuntu system
#
# @author Nicholas Wilde, 0x08b7d7a3
# @date 23 Jul 2022
# @version 0.1.0
#
################################################################################

set -e
set -o pipefail

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_NAME="$(basename "${0}")"
SCRIPT_DESC="Initialize the dotfiles on a Ubuntu system"

ORG_NAME="nicholaswilde"
GIT_DIR="${HOME}/git/${ORG_NAME}"
EMAIL_ADDRESS="ncwilde43@gmail.com"
REPO_NAME="dotfiles2"
REPO_URL="https://github.com/${ORG_NAME}/${REPO_NAME}"
REPO_DIR="${GIT_DIR}/${REPO_NAME}"

readonly EMAIL_ADDRESS
readonly GIT_DIR
readonly SCRIPT_PATH
readonly SCRIPT_NAME
readonly SCRIPT_DESC
readonly REPO_NAME
readonly ORG_NAME
readonly REPO_URL
readonly REPO_DIR


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

function prevent_subshell(){
  if [[ $_ != $0 ]]; then
    echo "Script is being sourced"
  else
    echo "Script is a subshell - please run the script by invoking . script.sh command"
    exit 1
  fi
}

function make_git_dir(){
  ! dir_exists "${GIT_DIR}" && mkdir -p "${GIT_DIR}"
  cd "${GIT_DIR}" || exit 1
}

function clone_repo(){
  if ! dir_exists "${REPO_DIR}"; then
    git clone "${REPO_URL}.git" "${REPO_DIR}"
  fi
  cd "${REPO_DIR}" || exit 1
}

function install_brew(){
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "${HOME}/.profile"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  sudo apt-get update
  sudo apt-get install -y build-essential
  source ~/.profile
}

function install_lastpass(){
  brew install lastpass-cli
  source ~/.profile
  lpass --trust login "${EMAIL_ADDRESS}"
}

function setup_ssh(){
  if ! command_exists ssh-import-id-gh; then
    sudo apt-get install -y ssh-import-id
  fi
  if ! dir_exists ~/.ssh; then
    mkdir ~/.ssh
  fi
  curl "https://github.com/${ORG_NAME}.keys" -o ~/.ssh/id_rsa.pub
  chmod 644 ~/.ssh/id_rsa.pub
  lpass show ssh --attach=att-4322045537695550419-20689 -q > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
  chmod 0700 ~/.ssh
  ssh-import-id-gh "${ORG_NAME}"
}

function setup_gpg(){
  
}

function main(){
  prevent_subshell
  make_git_dir
  clone_repo
  install_brew
  install_lastpass
  setup_ssh
  setup_gpg
}

main "$@"
