#!/bin/bash
# Check if command exists

check_args() {
  if [ -z "${2}" ]; then
    printf "Usage: \`%s\`\n" "${1}"
    return 1
  fi
}

function count() { ## Count the number of things
  check_args "count <dir>" "${1}" || return 1
  echo $(($(\find "${1}" -maxdepth 1 | wc -l)-1))
}

function targz() { ## Create a tarball
  check_args "targz <dir>" "${1}" || return 1
  	local tmpFile="${1%/}.tar"
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${1}" || return 1

	size=$(
	  stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
	  stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
	)

	local cmd=""
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli"
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz"
		else
			cmd="gzip"
		fi
	fi

	echo "Compressing .tar using \`${cmd}\`…"
	"${cmd}" -v "${tmpFile}" || return 1
	[ -f "${tmpFile}" ] && rm "${tmpFile}"
	unset cmd
	echo "${tmpFile}.gz created successfully."
}

if command_exists lynx; then
  function getcity() { ## Get the city of an IP address
    check_args "getcity <ip_address>" "${1}" || return 1
    lynx -dump "https://www.ip-adress.com/ip-address/ipv4/${1}" | grep 'City' | awk '{ s = ""; for (i = 3; i <= NF; i++) s = s $i " "; print s }';
  }

  function getip() { ## The the IP address of a domain
    check_args "getip <website>" "${1}" || return 1    
    lynx -dump "https://ipaddress.com/website/${1}" | grep -A1 "IPv4 Addresses" | tail -n 1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
  }
fi

if command_exists jq; then
  function getcom() { ## Get a short commit from a repo
    check_args "getcom <user/repo>" "${1}" || return 1  
    curl -s "https://api.github.com/repos/${1}/commits" | jq -r '.[0].sha' | \head -c 7 && printf "\n"
  }
fi

function getver() { ## Get the latest version from a repo
  check_args "getver <user/repo>" "${1}" || return 1  
  curl -s "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
  grep '"tag_name":' |                                        # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'                                # Pluck JSON value
}

function mkcdir() { ## Make and change to a directory
  check_args "mkcdir <dirname>" "${1}" || return 1
  \mkdir -p -- "${1}" &&
  \cd -P -- "${1}" || return
}

if command_exists kubectl; then
  function getsecret() { ## Get a secret
    check_args "getsecret <secret-name>" "${1}" || return 1
    # shellcheck disable=SC2016
    kubectl get secret "${1}" -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}'
  }
  function setns() { ## Set a namespace
    check_args "setns <namespace-name>" "${1}"|| return 1
    kubectl config set-context --current -n "$1"
  }
  function kubectlgetall() { ## Get all k8s namespaces
    check_args "kubectlgetall <namespace-name>" "${1}" || return 1
    for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
      echo "Resource:" "${i}"
      kubectl -n "${1}" get --ignore-not-found=true "${i}"
    done
  }
  # Apply SOPS encoded secret and then restore it
  # Requires private key to be in keyring.
  if command_exists sops; then
    function applyenc() { ## Apply SOPS encoded secret and restore it
      check_args "applyenc <file>.yaml" || return 1
      sops --decrypt --in-place "${1}"
      kubectl apply -f "${1}"
      git fetch
      branch="$(git branch --show-current)"
      git restore -s "origin/${branch}" -- "${1}"
      unset branch
    }
  fi
fi

function ssd() { ## Get SSD parameters
  echo "Device         Total  Used  Free   Pct MntPoint"
  df -h | grep "/dev/sd"
  df -h | grep "/mnt/"
}

function clone() { ## Clone a repo
  check_args "clone <user/repo>" "${1}"
  cd ~/git && \
  git clone "git@github.com:${1}.git" "${1}" && \
  cd "${1}" || return
}

function showpkg() { ## Show apt package info
  apt-cache "${1}" | grep -i "$1" | sort;
}

# Because I am a lazy bum, and this is
# surpisingly helpful..
function up() { ## Go up a number of directories
  if [ "$#" -eq 0 ]; then
    cd ../
  else
    for i in $(\seq 1 "${1}"); do
      cd ../
    done;
  fi
}

function weather() { ## Get the local weather
  if [ -z "$1" ]; then
    curl wttr.in
  else
    local s
    s=$*
    s="${s// /+}"
    curl "wttr.in/${s}"
  fi
}

function tmpd() { ## Make a temporary directory and enter it
  local dir
  if [ "$#" -eq 0 ]; then
    dir=$(mktemp -d)
  else
    dir=$(mktemp -d -t "${1}.XXXXXXXXXX")
  fi
  pushd "$dir" || return
}

function mwiki() { ## Lookup something on Wikipedia
  dig +short txt "$*".wp.dg.cx;
}

function dataurl() { ## Create a data URL from a file
  check_args "dataurl <file>" "${1}"
  local mimeType
  mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

function gz() { ## Compare original and gzipped file size
  check_args "gz <file>" "${1}"
  local origsize
  origsize=$(wc -c < "$1")
  local gzipsize
  gzipsize=$(gzip -c "$1" | wc -c)
  local bzipsize
  bzipsize=$(bzip2 -c "$1" | wc -c)
  local xzsize
  xzsize=$(xz -c "$1" | wc -c)
  local lzmasize
  lzmasize=$(xz -c "$1" | wc -c)
  local ratio
  local ratio2
  local ratio3
  local ratio4
  ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
  ratio2=$(echo "$bzipsize * 100 / $origsize" | bc -l)
  ratio3=$(echo "$xzsize * 100 / $origsize" | bc -l)
  ratio4=$(echo "$lzmasize * 100 / $origsize" | bc -l)
  printf "orig:  %d bytes\\n" "$origsize"
  printf "gzip:  %d bytes (%2.1f%%)\\n" "$gzipsize" "$ratio"
  printf "bzipz: %d bytes (%2.1f%%)\\n" "$bzipsize" "$ratio2"
  printf "xz:    %d bytes (%2.1f%%)\\n" "$xzsize" "$ratio3"
  printf "lzma:  %d bytes (%2.1f%%)\\n" "$lzmasize" "$ratio4"
}

function dcleanup() { ## Cleanup Docker stuff
  local containers
  mapfile -t containers < <(docker ps --filter status=exited -q 2>/dev/null)
  docker rm "${containers[@]}" 2>/dev/null
  local images
  mapfile -t images < <(docker images --filter dangling=true -q 2>/dev/null)
  docker rmi "${images[@]}" 2>/dev/null
}

# https://github.com/xvoland/Extract/blob/master/extract.sh
function extract() { ## Extract a compressed file
  if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 1
  else
    for n in "$@"; do
      if [ -f "$n" ] ; then
        case "${n%,}" in
          *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                        tar xvf "$n"         ;;
          *.lzma)       unlzma ./"$n"        ;;
          *.bz2)        bunzip2 ./"$n"       ;;
          *.cbr|*.rar)  unrar x -ad ./"$n"   ;;
          *.gz)         gunzip ./"$n"        ;;
          *.cbz|*.epub|*.zip) unzip ./"$n"   ;;
          *.z)          uncompress ./"$n"    ;;
          *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                        7z x ./"$n"          ;;
          *.xz)         unxz ./"$n"          ;;
          *.exe)        cabextract ./"$n"    ;;
          *.cpio)       cpio -id < ./"$n"    ;;
          *.cba|*.ace)  unace x ./"$n"       ;;
          *.zpaq)       zpaq x ./"$n"        ;;
          *.arc)        arc e ./"$n"         ;;
          *.cso)        ciso 0 ./"$n" ./"$n.iso" && \
                        extract ./"$n.iso" && \rm -f ./"$n" ;;
          *)
                       echo "extract: '$n' - unknown archive method"
                       return 1
                       ;;
        esac
      else
        echo "'$n' - file does not exist"
        return 1
      fi
    done
  fi
}

# https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
function urlencode() { ## Encode with URLEncode
	python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}

function urldecode() { ## Decode URLencoded string
	python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()), end='')"
}

# https://github.com/grml/grml-etc-core/blob/master/etc/zsh/zshrc
function bk() { ## Make a backup of a file
  check_args "bk <file>" "${1}" || return 1
  cp -a "$1" "${1}_$(date --iso-8601=seconds)"
}

# https://serverfault.com/a/6833/265446
function fawk() { ## Return a column number. df -h | awk '{print $2}' => df -h | fawk 2
  check_args "cmd | fawk <col_num>" "${1}" || return 1
  first="awk '{print "
  last="}'"
  cmd="${first}\$${1}${last}"
  eval "${cmd}"
}

function an() { ## Add notes
  check_args "an <file>.md" "${1}" || return 1
  "${EDITOR}" "${GIT_USER_PATH}/notes/docs/$1.md"
}

function lf() { ## List functions
  grep -Po "(?<=function ).*" ~/.bash_functions | sort | awk 'BEGIN {FS = "{.*?## "}; {printf "%-30s \033[36m%s\033[0m\n", $1, $2}'
}

function upgrate() { ## Upgrade everything
  sudo apt update
  sudo apt -y upgrade
  sudo apt -y autoremove
  command_exists npm && npm update -g
  command_exists pip3 && pip3 list --outdated --format=freeze | grep -v ^-e | cut -d = -f 1 | xargs -n1 pip3 install -U
  command_exists brew && brew upgrade
}

function fs() { ## Determine size of a file or total size of a directory
	if \du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh
	else
		local arg=-sh
	fi
	# shellcheck disable=SC2199
	if [[ -n "$@" ]]; then
		\du $arg -- "$@"
	else
		\du $arg -- *
	fi
}

function escape() { ## UTF-8-encode a string of Unicode symbols
  check_args "escape <string>" "${1}" || return 1
	local args
	mapfile -t args < <(printf "%s" "$*" | xxd -p -c1 -u)
	printf "\\\\x%s" "${args[@]}"
	# print a newline unless we’re piping the output to another program
	if [ -t 1 ]; then
		echo ""; # newline
	fi
}

if command_exists perl; then
  function codepoint() { ## Get a character’s Unicode code point
    check_args "codepoint <string>" "${1}" || return 1
  	perl -e "use utf8; print sprintf('U+%04X', ord(\"$*\"))"
  	# print a newline unless we’re piping the output to another program
  	if [ -t 1 ]; then
  		echo ""; # newline
  	fi
  }
fi

function mkig () { ## Make .gitignore file.
  check_args "mkig <lang1,lang2>" "${1}" || return 1
  curl -L -s "https://www.gitignore.io/api/$*"
}

function separator() { ## Print a separator
  # https://stackoverflow.com/a/42762743
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
}

function repeat() { ## Repeat a string
  if is_null "${1}"; then
    local s="-"
  else
    local s="${1}"
  fi
  if is_null "${2}"; then
    local n=80
  else
    local n="${2}"
  fi
  for ((i=1; i <= n; i++)); do
    echo -n "${s}"
  done
}

function repeatln(){ ## Repeat a string and print a new line
  repeat "${1}" "${2}"
  printf "\n"
}

function replacetabs() { ## Replace tabs in a file with spaces
  check_args "replacetabs <file> [n spaces]" "${1}" || return 1
  if is_null "${2}"; then
    local n=2
  else
    local n="${2}"
  fi
  s=$(repeat " " "${n}")
  sed -i "s/\t/${s}/g" "${1}"
}

function emojisc() { ## Lookup an emoji shortcode
  check_args "emojisc <emoji>" "${1}" || return 1
  # local type="github/\">Github</a>"
  local type="slack/\">Slack</a>"
  # local type="shortcodes/\">Emojipedia</a>"
  curl -kLss "https://emojipedia.org/search/?q=${1}" | grep -B 1 "${type}" | grep -oP '^[^\:]*\:\K[^\:]+'
}

function emojis() { ## Search Emojipedia for emoji
  check_args "emojis <word>" "${1}" || return 1
  curl -kLss "https://emojipedia.org/search/?q=${1}" | grep "<span class=\"emoji\">" | grep h2 | awk -F"<span class=\"emoji\">|</a>" '{for(i=2;i<=NF;i+=2){print $i}}' RS="" | sed "s/<\/span>//g"
}

function cpdeg() { ## Copy degree symbol, °
  printf "%s" "°"| copy
}

function bwfind() {
  bw list items --search $1 | jq '.[] | .name,.login'
}
