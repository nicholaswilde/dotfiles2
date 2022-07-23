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
GIT_DIR="${HOME}/git/nicholaswilde"
readonly GIT_DIR
readonly SCRIPT_PATH
readonly SCRIPT_NAME
readonly SCRIPT_DESC

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

function make_git_dir(){
  ! dir_exists "${GIT_DIR}" && mkdir -p "${GIT_DIR}"
  cd "${GIT_DIR}" || exit 1
}

function clone_repo(){
  ! dir_exists "${GIT_DIR}/dotfiles2" && dir_exists git clone https://github.com/nicholaswilde/dotfiles2.git "${GIT_DIR}/dotfiles2"
  cd "${GIT_DIR}/dotfiles2" || exit 1
}

function install_brew(){
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "${HOME}/.profile"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  sudo apt-get update
  sudo apt-get install build-essential
  source "${HOME}/.profile"
}

function install_lastpass(){
  brew install lastpass-cli
}

function main(){
  make_git_dir
  clone_repo
  install_brew
  install_lastpass
}

main "$@"
