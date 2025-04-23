#!/usr/bin/env bash
################################################################################
#
# dotfiles
# ----------------
# Install dotfiles on system
#
# @author Nicholas Wilde, 0xb299a622
# @date 23 Apr 2025
# @version 0.1.0
#
################################################################################

set -e
set -o pipefail

bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
blue=$(tput setaf 4)
default=$(tput setaf 9)
white=$(tput setaf 7)
yellow=$(tput setaf 3)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

echo $DIR

readonly bold
readonly normal
readonly red
readonly blue
readonly default
readonly white
readonly yellow
readonly DIR

function print_text(){
  echo "${blue}==> ${white}${bold}${1}${normal}"
}

function show_warning(){
  printf "${yellow}%s\n" "${1}${normal}"
}

function raise_error(){
  printf "${red}%s\n" "${1}${normal}"
  exit 1
}

# Check if variable is set
# Returns false if empty
function is_set(){
  [ -n "${1}" ]
}

function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

function mklinks(){
  print_text "Installing dotfiles"
  for file in $(find "${DIR}" -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg" -not -name "test.sh" -not -name ".bashrc.*" -not -name ".yamllint" -not -name ".pre-commit-config*"); do
    f=$(basename $file)
    echo "${f}"
    # ln -sfn "${file}" "${HOME}/${f}"
  done
}

function setup_gpg(){
  print_text "Setting up gpg"
  gpg --list-keys || true
  [[ -d "${HOME}/.gnupg" ]] || mkdir -p "${HOME}/.gnupg"
  for file in $(find $(pwd)/.gnupg); do
    f=$(basename $file)
    ln -sfn "${file}" "${HOME}/.gnupg/${f}"
  done
}

function setup_gh(){
  print_text "Setting up gh"
  [[ -d "${HOME}/.config/gh" ]] || mkdir -p "${HOME}/.config/gh"
  ln -snf "$(pwd)/.config/gh/config.yml" "${HOME}/.config/gh/config.yml"
}

function setup_micro(){
  print_text "Setting up micro"
  [[ -d "${HOME}/.config/micro/syntax/" ]] || mkdir -p "${HOME}/.config/micro/syntax/"
  ln -snf "$(pwd)/.config/micro/settings.json" "${HOME}/.config/micro/settings.json"
  ln -snf "$(pwd)/.config/micro/bindings.json" "${HOME}/.config/micro/bindings.json"
  ln -snf "$(pwd)/.config/micro/syntax/sh.yaml" "${HOME}/.config/micro/syntax/sh.yaml"

  print_text "Setting up catppuccin for micro"
  TEMP=$(mktemp -d)
  print_text "Temp: ${TEMP}"
  [[ -d "${HOME}/.config/micro/colorschemes" ]] || mkdir -p "${HOME}/.config/micro/colorschemes"
  git clone "https://github.com/catppuccin/micro.git" "${TEMP}"
  CLONE_PID=$!
  print_text "CLONE_PID: ${CLONE_PID}"
  if [ $? -eq 0 ]; then
    cp "${TEMP}/src/*" "${HOME}/.config/micro/colorschemes"
  fi
}

function setup_tmux(){
  print_text "Setting up tmux"
  git clone "https://github.com/tmux-plugins/tpm" "${HOME}/.tmux/plugins/tpm"
  [[ -d "${HOME}.config/tmux" ]] || mkdir -p "${HOME}.config/tmux"
  [[ -d "${HOME}/.config/tmux/plugins/catppuccin" ]] || mkdir -p "${HOME}/.config/tmux/plugins/catppuccin"
  git clone "https://github.com/catppuccin/tmux.git" "${HOME}/.config/tmux/plugins/catppuccin/tmux"
  ln -snf "$(pwd)/.config/tmux/tmux.conf" "${HOME}/.config/tmux/tmux.conf"
  bash -c "${HOME}/.tmux/plugins/tpm/bin/install_plugins"
}

function setup_cheat(){
  print_text "Setting cheat"
  [[ -d "${HOME}/.config/cheat" ]] || mkdir -p "${HOME}/.config/cheat"
  ln -snf "$(pwd)/.config/cheat/conf.yml" "${HOME}/.config/cheat/conf.yml"
}

function main(){
  print_text "test"
  mklinks
  setup_gpg
  setup_gh
  setup_micro
  # setup_tmux
  # setup_cheat
  # source ~/.bashrc
}

main "@"
