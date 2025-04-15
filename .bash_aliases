#!/bin/bash

alias relogin='exec $SHELL -l'

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Add an "alert" alias for long running commands.  Use like so: sleep 10; alert

command_exists notify && alias alert='notify "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# nano
if file_exists ~/.nanorc; then
  # don't allow tabs
  alias utab="sed '/^#.*tabstospaces/s/^#//' -i ~/.nanorc"
  # allow tabs
  alias tab="sed '/^set tabstospaces/s/^/#/' -i ~/.nanorc"
fi

# pass
if command_exists pass; then
  # main is the name of the repo branch
  alias passpull='pass pull origin main'
  alias passpush='pass git push -u --all'
fi

# Remove the file by default
command_exists shred && alias shred='shred -u'

command_exists fping &&	alias pingall='fping -l 192.168.1.202 192.168.1.203 192.168.1.189 192.168.1.195 192.168.1.199 192.168.1.172 192.168.1.201'

#boinc-client
if command_exists boinccmd; then
  alias getstate='boinccmd --get_state'
  alias gettasks='boinccmd --get_tasks'
  alias getoldtasks='boinccmd --get_old_tasks'
fi

# ansible
if command_exists ansible; then
  alias ap='ansible-playbook'
  alias rebootcluster='ansible k3s_cluster -a "reboot" -b'
fi

if alias upgrate 2>/dev/null; then
  unalias upgrate
fi

# Apt
if command_exists apt; then
  alias apt-get='sudo apt-get'
  # alias upgrate='sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove && brew update && npm update -g && pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U && brew upgrade'
  alias cleanup='sudo apt autoremove -y && sudo apt autoclean'
  alias install='sudo apt install -y'
  alias remove='sudo apt remove'
  alias purge='sudo apt remove --purge'
fi

# openports
alias openports='sudo lsof -i -P -n | grep LISTEN'

# Find files
alias search='sudo find / -name'
alias fhere='find . -name'

# Navigation
# if command_exists mc; then
#   alias ls='mc ls'
#   alias cp='mc cp'
#   alias cat='mc cat'
#   alias mkdir='mc mb'
#   alias pipe='mc pipe'
#   alias find='mc find'
#   alias sl='mc ls'
#   # alias mv='mc mv'
#   # alias rm='mc rm'
#   alias watch='mc watch'
#   alias head='mc head'
#   alias tree='mc tree'
#   alias diff='mc diff'
#   alias du='mc du'
# else
  alias ls='ls --sort=extension --color=auto'
  alias sl='ls --sort=extension --color=auto' # Typo
  alias lsl='ls -lhFA | less' # Long format
  alias ll='ls -lh'
  alias lal='ls -alh'
  alias la='ls -A'
  alias l='ls -CF'
  # File attributes
  alias rm='rm -rf'
  alias cp='cp -r'
  alias mv='mv -i'
  alias mkdir='mkdir -pv' # Parent directories  
# fi

alias rm='rm -rf'

alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias back='cd "$OLDPWD"'
alias ~='cd ~'

# System
alias pms='sudo pm-suspend'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# pydf
command_exists pydf && alias df='pydf -ha'

alias du='du -ach | sort -h'
alias free='free -mt'
alias ps='ps auxf'
alias histg='history | grep'

# Change to using htop
command_exists htop && alias top='htop'

# Editor
if command_exists nano; then
  alias sn='sudo nano'
  alias n='nano'
fi

if command_exists micro; then
  alias sm='sudo micro'
  alias m='micro'
fi

alias e='${EDITOR}'

# List our functions
# alias lf='cat ~/.bash_functions|grep -o -P "(?<=function ).*(?=\(\))" | sort'
if alias lf 2>/dev/null; then
  unalias lf
fi

# Cool colors for man pages
alias man="TERMINFO=~/.terminfo TERM=mostlike LESS=C PAGER=less man"

# Enable color support of ls and also add handy aliases
if dir_exists /usr/bin/dircolors; then
  # shellcheck disable=SC2015
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# This one is to take care of make
# Give me a nice, distinguishable make output
if command_exists make; then
  alias make='clear && make'
  alias m='make'
  alias smi='sudo make install'
fi

# Downloads
command_exists wget && alias wget='wget -c'

# Git Commands
if command_exists git; then
  alias gpo='git push origin main'
  alias gps='git push origin source'
  alias gpma='git push origin master'
  alias gp='git pull origin $(git branch --show-current)'
  alias gs='git status'
  alias gd='git diff'
  alias gr='git reflog'
  alias glf='git ls-files'
  alias ga='git add'
  alias gl='git log'
  alias revert='git reset --hard'
  alias gc='git commit -s -m'
  alias gb='git branch'
fi

# Color the output of cat
command_exists pygmentize && alias catc='pygmentize -O style=friendly -g' # sudo apt-get install python3-pygments

# Get my public ip
alias pubip='curl http://ipecho.net/plain; echo'
# shellcheck disable=SC2142
alias localip="hostname -I | awk '{print \$1}'"

# Docker
if command_exists docker; then
  alias dc='docker-compose'
  # Restart builder https://github.com/nicholaswilde/docker-template/wiki/Troubleshooting#restart-buildkit
  alias dr='docker restart buildx_buildkit_multiarch0'
fi

# kubectl
if command_exists kubectl; then
  alias k=kubectl
  alias kge='kubectl get events'
  alias ke='kubectl edit'
  alias kg='kubectl get'
  alias kgp='kubectl get pods -o wide'
  alias kgn='kubectl get namespaces -o wide'
  alias kga='kubectl get all -o wide'
  alias ka='kubectl apply'
  alias kaf='kubectl apply -f'
  alias kgi='kubectl get ingress'
  alias kl='kubectl logs'
  alias kdesc='kubectl describe'
  alias kdel='kubectl delete'
  alias wkp='watch kubectl get pods -o wide'
  alias wkns='watch kubectl get ns -o wide'
  alias wka='watch kubectl get all -o wide'
  alias getkubeconfig='scp pirate@192.168.1.201:~/.kube/config ~/.kube/config-turing-pi'
  alias restartpod='kubectl rollout restart deployment'
  # shellcheck disable=SC2142
  alias geting="kubectl get all -n kube-system | grep '^service/traefik ' | awk '{print \$4}'"
  # shellcheck disable=SC2139
  alias klcm="kubectl logs -n cert-manager $(kubectl get pods -n cert-manager --selector=app.kubernetes.io/name=cert-manager -o jsonpath='{.items[*].metadata.name}')"
  alias kgef='kubectl get events -n flux-system'
fi

# Edit files
test -f "${ALIASES_PATH}" && alias ea='${EDITOR} ${ALIASES_PATH}'
test -f "${COMPLETIONS_PATH}" && alias ec='${EDITOR} ${COMPLETIONS_PATH}'
test -f "${EXPORTS_PATH}" && alias ee='${EDITOR} ${EXPORTS_PATH}'
test -f "${FUNCTIONS_PATH}" && alias ef='${EDITOR} ${FUNCTIONS_PATH}'
test -f "${BASHRC_PATH}" && alias erc='${EDITOR} ${BASHRC_PATH}'

# Quickly load bashrc
alias reload='brew leaves > ${GIT_USER_PATH}/dotfiles2/formulas  && source ~/.bashrc && git -C ${GIT_USER_PATH}/dotfiles2 add ${GIT_USER_PATH}/dotfiles2/* && git -C ${GIT_USER_PATH}/dotfiles2 commit --allow-empty-message -a -m ""; git -C ${GIT_USER_PATH}/dotfiles2 push origin main'
alias gcn='git -C ${GIT_USER_PATH}/notes add ${GIT_USER_PATH}/notes/* &&  git -C ${GIT_USER_PATH}/notes commit --allow-empty-message -a -m ""; git -C ${GIT_USER_PATH}/notes push origin main'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# copy
if command_exists copy; then
  alias cwd='pwd | tr -d "\r\n"| copy'
  alias pubkey="more ~/.ssh/id_rsa.pub | copy && printf '=> Public key copied to clipboard.\n'"
  alias prikey="more ~/.ssh/id_rsa | copy && printf '=> Private key copied to clipboard.\n'"
fi

# tar
command_exists tar && alias untar='tar xvf'

# boilerplater
if command_exists boilerplater; then
  alias boilerbash='boilerplater bash'
  alias boilerpy='boilerplater python'
  alias boilermd='boilerplater ${GIT_USER_PATH}/dotfiles/bin/boilerplate-md README.md'
fi

# netstat
command_exists netstat && alias port='netstat -tulanp'

# 32 or 64 bit
# https://www.commandlinefu.com/commands/view/2940/32-bits-or-64-bits
alias bit='getconf LONG_BIT'

# mkdocs
command_exists mkdocs && alias mk='mkdocs build -f ../mkdocs.yaml && mkdocs serve --dev-addr 0.0.0.0:8000 -f ../mkdocs.yaml'

# hugo
command_exists hugo && alias hs='hugo server -w --bind 0.0.0.0 --disableFastRender'

# Helm
if command_exists helm; then
  alias hi='helm install'
  alias hu='helm uninstall'
  alias hdu='helm dependency update'
fi

# Flux
if command_exists flux; then
  alias wfk='watch flux get kustomizations'
  alias wfh='watch flux get helmreleases'
  alias wfs='watch flux get sources all -A'
  alias f='flux'
  alias fs='flux reconcile source git flux-system'
fi

# SOPS
if command_exists sops; then
  alias se='sops --encrypt --in-place'
  alias sd='sops --decrypt --in-place'
fi

alias pi-04='ssh pi@192.168.1.192'
alias main='ssh pi@192.168.1.201'

if command_exists terraform; then
  alias tf='terraform'
fi

if command_exists terragrunt; then
  alias tg='terragrunt'
fi

if command_exists ansible-vault; then
  alias av='ansible-vault'
fi
