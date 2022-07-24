printf "\ninstalling dotfiles ...\n\n"
for file in $(find $(pwd)/.. -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg" -not -name "test.sh" -not -name ".bashrc.*" -not -name ".yamllint" -not -name ".pre-commit-config*"); do
  f=$(basename $file);
  ln -sfn $file "${HOME}/$f";
done;
gpg --list-keys || true;
mkdir -p "${HOME}/.gnupg";
for file in $(find $(pwd)/../.gnupg); do
  f=$(basename $file);
  ln -sfn $file "${HOME}/.gnupg/$f";
done;
mkdir -p "${HOME}/.config/gh";
ln -snf "$(pwd)/../.config/gh/config.yml" "${HOME}/.config/gh/config.yml";
mkdir -p "${HOME}/.config/micro";
ln -snf "$(pwd)/../.config/micro/settings.json" "${HOME}/.config/micro/settings.json";
ln -snf "$(pwd)/../.config/micro/bindings.json" "${HOME}/.config/micro/bindings.json";
source ~/.bashrc
