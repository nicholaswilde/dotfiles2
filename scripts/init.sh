#!/bin/bash

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
  git clone https://github.com/nicholaswilde/dotfiles2.git "${GIT_DIR}/dotfiles2"
  cd "${GIT_DIR}/dotfiles2" || exit 1
}

function main(){
  make_git_dir
  clone_repo
}

main "$@"
