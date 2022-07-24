# Configuration

## :page_with_curl: `init.sh` Script

Variables inside the script may be changed to customize the repo.

| Variable name         | Description                                             | Default value                                 |
|-----------------------|---------------------------------------------------------|-----------------------------------------------|
| `ORG_NAME`            | The GitHub organization name                            | `nicholaswilde`                               |
| `GIT_DIR`             | The git directory in which the repo is is cloned        | `${HOME}/git/${ORG_NAME}`                     |
| `EMAIL_ADDRESS`       | The email address used to log into `lastpass-cli`       | `ncwilde43@gmail.com`                         |
| `REPO_NAME`           | The name of the GitHub repository                       | `dotfiles2`                                   |
| `REPO_URL`            | The URL of the repository                               | `git@github.com:${ORG_NAME}/${REPO_NAME}.git` |
| `REPO_DIR`            | The directory to which the repo is locally cloned       | `${GIT_DIR}/${REPO_NAME}`                     |
| `GPG_LPASS_ID`        | The ID of the GPG `lastpass-cli` entry                  | `gpg`                                         |
| `GPG_LPASS_ATTACH_ID` | The attachment ID of the GPG `lastpass-cli` private key | `att-8017296795546256342-55097`               |
| `SSH_LPASS_ID`        | The ID of the SSH `lastpass-cli` entry                  | `ssh`                                         |
| `SSH_LPASS_ATTACH_ID` | The attachment ID of the SSH `lastpass-cli` private key | `att-4322045537695550419-20689`               |

## :card_file_box: Dotfiles

New dotfiles just need to be added to the root directory of the repo and task will then
automatically add a symbolic link when `task dotfiles` is run.

## :gear: Config Files

New config files need to be added to the `.config` repo directory and then the `dotfiles` task in `Taskfile.yaml`
needs to be updated.
