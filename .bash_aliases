# Check if command exists
function command_exists(){
  command -v "${1}" &> /dev/null
}

# Check is variable is null
function is_null {
  [ -z "$1" ]
}

# Check if directory exists
function dir_exists(){
  [ -d "${1}" ]
}

# Check if file exists
function file_exists(){
  [ -f "{1}" ]
}

# nano
if [ -f "${HOME}/.nanorc" ]; then
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
command_exists shred &&  alias shred='shred -u'

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

# Apt
if command_exists apt; then
  alias apt-get='sudo apt-get'
  alias upgrate='sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove && brew update && npm update -g && pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U && brew upgrade'
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
if command_exists mc; then
  alias ls='mc ls'
  alias cp='mc cp'
  alias cat='mc cat'
  alias mkdir='mc mb'
  alias pipe='mc pipe'
  alias find='mc find'
  alias sl='mc ls'
  alias mv='mc mv'
  #alias rm='mc rm'
  alias watch='mc watch'
  alias head='mc head'
  alias tree='mc tree'
  alias diff='mc diff'
  alias du='mc du'
  
else
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
  
fi

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

# List our functions
alias lf='cat ~/.bash_functions|grep -o -P "(?<=function ).*(?=\(\))"'

# Cool colors for man pages
alias man="TERMINFO=~/.terminfo TERM=mostlike LESS=C PAGER=less man"

# Enable color support of ls and also add handy aliases
if dir_exists /usr/bin/dircolors; then
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
    alias geting="kubectl get all -n kube-system | grep '^service/traefik ' | awk '{print \$4}'"
    alias klcm="kubectl logs -n cert-manager $(kubectl get pods -n cert-manager --selector=app.kubernetes.io/name=cert-manager -o jsonpath='{.items[*].metadata.name}')"
    alias kgef='kubectl get events -n flux-system'
fi

# Edit files
alias ea='${EDITOR} ~/.bash_aliases'
alias ee='${EDITOR} ~/.bash_exports'
alias ef='${EDITOR} ~/.bash_functions'
alias ec='${EDITOR} ~/.bash_completions'
alias el='${EDITOR} /usr/local/lib/bash/libbash'

# Quickly load bashrc
alias reload='brew leaves > ~/git/nicholaswilde/dotfiles/formulas  && source ~/.bashrc && git -C ~/git/nicholaswilde/dotfiles add ~/git/nicholaswilde/dotfiles/* &&  git -C ~/git/nicholaswilde/dotfiles commit --allow-empty-message -a -m ""; git -C ~/git/nicholaswilde/dotfiles push origin main'
alias gcn='git -C ~/git/nicholaswilde/notes add ~/git/nicholaswilde/notes/* &&  git -C ~/git/nicholaswilde/notes commit --allow-empty-message -a -m ""; git -C ~/git/nicholaswilde/notes push origin main'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

command_exists copy && alias cwd='pwd | tr -d "\r\n"| copy'
command_exists tar && alias untar='tar xvf'

alias pubkey="more ~/.ssh/id_rsa.pub | copy && printf '=> Public key copied to clipboard.\n'"
alias prikey="more ~/.ssh/id_rsa | copy && printf '=> Private key copied to clipboard.\n'"

command_exists boilerplater && alias boilerbash='boilerplater bash'
command_exists boilerplater && alias boilerpy='boilerplater python'
command_exists boilerplater && alias boilermd='boilerplater ~/git/nicholaswilde/dotfiles/bin/boilerplate-md README.md'
command_exists netstat && alias port='netstat -tulanp'
command_exists lynx && alias city="lynx -dump https://www.ip-adress.com/ip-address/ipv4/$(curl -s http://ipecho.net/plain; echo) | grep 'City' | awk '{print \$2,\$3,\$4,\$5,\$6}'"

# 32 or 64 bit
# https://www.commandlinefu.com/commands/view/2940/32-bits-or-64-bits
alias bit='getconf LONG_BIT'

command_exists mkdocs && alias mk='mkdocs build -f ../mkdocs.yaml && mkdocs serve --dev-addr 0.0.0.0:8000 -f ../mkdocs.yaml'

command_exists hugo && alias hs='hugo server -w --bind 0.0.0.0 --disableFastRender'

# Helm
command_exists helm && alias hi='helm install'
command_exists helm && alias hu='helm uninstall'
command_exists helm && alias hdu='helm dependency update'

# Flux
command_exists flux && alias wfk='watch flux get kustomizations'
command_exists flux && alias wfh='watch flux get helmreleases'
command_exists flux && alias wfs='watch flux get sources all -A'
command_exists flux && alias f='flux'
command_exists flux && alias fs='flux reconcile source git flux-system'

# SOPS
command_exists sops && alias se='sops --encrypt --in-place'
command_exists sops && alias sd='sops --decrypt --in-place'

alias pi-04='ssh pi@192.168.1.192'
alias main='ssh pi@192.168.1.201'
