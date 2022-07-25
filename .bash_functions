# Ensure that the function start with the word 'function' and end with '()" so
# that the alias list function (lf) parses the function correctly.

# Check if command exists
function command_exists(){
  command -v "${1}" &> /dev/null
}

function count(){
  if [ -z "${1}" ]; then
    echo "Usage: \`count dir\`"
    return 1
  fi  
  echo $(ls ${1} | wc -l)
}

# Create a tar ball
function targz() {
  if [ -z "${1}" ]; then
    echo "Usage: \`targz dir\`"
    return 1
  fi
  tar -zcvf $(echo ${1} | sed 's/^\.//' | cut -f 1 -d '.').tar.gz ${1}
}

if command_exists lynx; then
  function getloc() {
    if [ -z "${1}" ]; then
        echo "Usage: \`getloc ip_address\`"
        return 1
    fi
    lynx -dump "https://www.ip-adress.com/ip-address/ipv4/${1}" | grep 'City' | awk '{print $2,$3,$4,$5,$6}';
  }
fi

function getcom() {
  if [ -z "${1}" ]; then
    echo "Usage: \`getcom user/repo\`"
    return 1
  fi
  printf "$(curl -s "https://api.github.com/repos/${1}/commits" | jq -r '.[0].sha' | \head -c 7)\n"
}

function getver() {
  if [ -z "${1}" ]; then
    echo "Usage: \`getver user/repo\`"
    return 1
  fi
  curl -s "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
  grep '"tag_name":' |                                        # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'                                # Pluck JSON value
}

function mkcdir() {
  if [ -z "${1}" ]; then
    echo "Usage: \`mkcdir dirname\`"
    return 1
  fi
  mkdir -p -- "${1}" &&
  cd -P -- "${1}"
}

if command -v kubectl &> /dev/null; then
  function getsecret(){
    if [ -z "${1}" ]; then
      echo "Usage: \`getsecret secret-name\`"
      return 1
    fi
    kubectl get secret "${1}" -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}'
  }
  function setns(){
    if [ -z "${1}" ]; then
      echo "Usage: \`setns namespace-name\`"
      return 1
    fi
    kubectl config set-context --current -n "$1"
  }
  function kubectlgetall() {
    if [ -z "${1}" ]; then
      echo "Usage: \`kubectlgetall namespace-name\`"
      return 1
    fi
    for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
      echo "Resource:" "${i}"
      kubectl -n "${1}" get --ignore-not-found=true "${i}"
    done
  }
fi

function ssd(){
  echo "Device         Total  Used  Free   Pct MntPoint"
  df -h | grep "/dev/sd"
  df -h | grep "/mnt/"
}

function clone(){
  cd ~/git
  git clone git@github.com:$1.git $1
  cd $1
}

function showpkg() {
  apt-cache $1 | grep -i "$1" | sort;
}

if command -v git &> /dev/null; then
  function gc(){ git commit -m "$*"; }
fi

# Because I am a lazy bum, and this is
# surpisingly helpful..
function up() {
  for i in `seq 1 $1`; do
    cd ../
  done;
}

# Make a temporary directory and enter it
function tmpd() {
  local dir
  if [ $# -eq 0 ]; then
    dir=$(mktemp -d)
  else
    dir=$(mktemp -d -t "${1}.XXXXXXXXXX")
  fi
  cd "$dir" || exit
}

# Create a data URL from a file
function dataurl() {
  local mimeType
  mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Create a git.io short URL
function gitio() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    echo "Usage: \`gitio slug url\`"
    return 1
  fi
  curl -i https://git.io/ -F "url=${2}" -F "code=${1}"
}

# Compare original and gzipped file size
function gz() {
  if [ -z "${1}" ]; then
    echo "Usage: \`gz file\`"
    return 1
  fi
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

function dcleanup(){
  local containers
  mapfile -t containers < <(docker ps --filter status=exited -q 2>/dev/null)
  docker rm "${containers[@]}" 2>/dev/null
  local images
  mapfile -t images < <(docker images --filter dangling=true -q 2>/dev/null)
  docker rmi "${images[@]}" 2>/dev/null
}

# https://github.com/xvoland/Extract/blob/master/extract.sh
function extract {
  if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
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
            *.cbz|*.epub|*.zip) unzip ./"$n"  ;;
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
                            extract $n.iso && \rm -f $n ;;
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
# Encode with URLEncode
function urlencode() {
	python -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}

# Decode URLencoded string
function urldecode() {
	python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()), end='')"
}

# make a backup of a file
# https://github.com/grml/grml-etc-core/blob/master/etc/zsh/zshrc
function bk() { cp -a "$1" "${1}_$(date --iso-8601=seconds)"; }

# https://serverfault.com/a/6833/265446
function fawk() {
    first="awk '{print "
    last="}'"
    cmd="${first}\$${1}${last}"
    eval $cmd
}

# Add notes
function an() {
  if [ -z "${1}" ]; then
    # display usage if no parameters given
    echo "Usage: an <file>.md"
    return 1
  fi
  "${EDITOR}" "~/git/nicholaswilde/notes/docs/$1.md"
}

# Apply SOPS encoded secret and then restore it
# Requires private key to be in keyring.
function applyenc() {
  if [ -z "${1}" ]; then
    # display usage if no parameters given
    echo "Usage: applyenc <file>.yaml"
    return 1
  fi
  sops --decrypt --in-place "${1}"
  kubectl apply -f "${1}"
  git fetch
  git restore -s origin/$(git branch --show-current) -- "${1}"
}
