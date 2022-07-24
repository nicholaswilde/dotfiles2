# Usage

## :page_with_curl: `init.sh` Script

The `init.sh` script is a remote script used to setup a debian system from scratch.
It installs some of the first on the system without having to clone the repository nor
perform any other manual tasks.

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicholaswilde/dotfiles2/main/scripts/init.sh)"
```

The script performs the following tasks:

### :beer: Install Homebrew

[Homebrew][1] is a package manager that is used to install [the stuff you need][2] that Apple
(or your Linux system) didn't. Installing brew with the `init.sh` script allows the ease of
installation for `go-task` and `lastpass-cli`.

!!! note
    brew is [not available for `arm` systems][3].
    
The Homebrew installation also adds the bash completion to the `~/.profile` file but needs to be manually sourced.

The [`build-essential` apt package][14] is also installed.

### :robot: Install Task

[Task][4] is a task runner / build tool that aims to be simpler and easier to use than, for example, GNU Make.
The dotfiles2 repo uses `Task` to easily install the dotfiles as well as perform other tasks.

Run `task` to list the current list of tasks supported by the repo. 

```shell
task
task: Available tasks for this project:
* dotfiles:     Install dotfiles
* export:       Export brew formulas
* import:       Import brew formulas
* init:         Initialize remote dotfiles
* init-local:   Initialize local dotfiles
* serve:        Serve an mkdocs server
* venv:         Run virtual environment
```

!!! note
    The tasks listed above may be out of date to the actual tasks in the repo.

### :old_key: Install `lastpass-cli`

[lastpass-cli][5] is a command line tool for [LastPass][6] and is used to store and retrieve the SSH and GPG keys.

The `lastpass-cli` command will also prompt you to login.

```shell
...
==> lastpass-cli
Bash completion has been installed to:
  /home/linuxbrew/.linuxbrew/etc/bash_completion.d
Please enter the LastPass master password for <email@email.com>.

Master Password:
```

### :fontawesome-solid-terminal: Setup SSH

A private SSH key is imported from `lastpass-cli`. The script uses either the name of the `lastpass-cli` entry or the `id`.
The repo also imports the private key from an [secure note attachment][10] rather than the `Private Key` field to reduce the risk of
copying and pasting the key incorrectly.

The name of the GPG secure note below is `ssh`.

```shell
lpass show ssh
ssh [id: 4322045537695550419]
Language: en-US
Bit Strength: 
Format: 
Passphrase: None
Private Key: -----BEGIN OPENSSH PRIVATE KEY-----
Public Key: ssh-rsa ....
Hostname: 
Date: June,22,2021
NoteType: SSH Key
att-4322045537695550419-20689: id_rsa.txt
```

The secret key is saved in a text file titled `id_rsa.txt` and saved as attachment `att-4322045537695550419-20689`.

!!! note
    LastPass only saves attachments with [certain file extensions][10] and so the `id_rsa` file needs to be saved with
    a `*.txt` file extensions before saving it as a LastPass attachment.

The script also imports the [public SSH key from GitHub][11] using the `ssh-import-id-gh` command from the [`ssh-import-id` apt package][12].

Example public key URL:

- <https://github.com/nicholaswilde.keys>
        
### :lock: Setup GPG

A private GPG key is imported from `lastpass-cli`. The script uses either the name of the `lastpass-cli` entry or the `id`.
The repo also imports the private key from an secure note attachment rather than the `Private Key` field to reduce the risk of
copying and pasting the key incorrectly.

The name of the GPG secure note below is `gpg`.

```shell
lpass show gpg
gpg [id: 8017296795546256342]
Date: June,20,2022
Hostname: 
Public Key: -----BEGIN PGP PUBLIC KEY BLOCK-----
Private Key: -----BEGIN PGP PRIVATE KEY BLOCK-----
Passphrase: None
Format: 
Bit Strength: 
Language: en-US
NoteType: SSH Key
att-8017296795546256342-55097: secret-key-backup.asc.txt
Notes: 
```

The secret key is saved in a text file titled `secret-key-backup.asc.txt` and saved as attachment `att-8017296795546256342-55097`.

The script also refreshes the key from the [Ubuntu keyserver][9].

```shell
...
gpg: refreshing 1 key from hkp://keyserver.ubuntu.com
gpg: key F08AD0AD08B7D7A3: "Nicholas Wilde <ncwilde43@gmail.com>" 1 new signature
gpg: Total number processed: 1
gpg:         new signatures: 1
...
```

### :sheep: Clone `dotfiles2` Repository

The repo is cloned using the [GitHub SSH URL][8] to enable the ease of connection with the remote repo.
When cloning, git will prompt whether you'd like to continue connecting. Type `yes` and `enter` to continue
the connection.

```shell
...
==> Clone repo
Cloning into '/home/ubuntu/git/nicholaswilde/dotfiles2'...
The authenticity of host 'github.com (192.30.255.112)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? 
```

### :checkered_flag: `init.sh` Completion

There currently isn't a way to source the dotfiles in the current shell using the `init.sh` script. Therefore,
the `.profile` file needs to be manually sourced.

```shell
...
==> dotfiles init complete
- Source the profile file to gain access to brew commands:
    source ~/.profile
```

## Dotfiles Repo

### :floppy_disk: Installation

The dotfiles are installed as symbolic links to the home folder pointing to the repository location. That way 
when the dotfiles are updated in the home folder, the repo sees the files as modified and can be then updated and pushed
to the remote repo.

The dotfiles can be installed by running the following commands:

```shell
cd /home/ubuntu/git/nicholaswilde/dotfiles2
task dotfiles
```

!!! warning
    Ensure that your current dotfiles in the home directory are backed up before installing the repo dotfiles.

!!! warning
    There currently is not an automatic way of uninstalling the dotfiles once installed.

### :beer: Homebrew Formulas

Homebrew formulas are automatically backed up to the [`formulas` file][7] when the `reload` alias is ran.

The `formulas` import and backup may also be manually ran by running the following commands:

=== "Task"
    ```bash
    # Import brew formulas from the formulas file.
    task import
    # Export brew formulas to the formulas file.
    task export
    ```
=== "Manual"
    ```bash
    # Import brew formulas from the formulas file.
    brew leaves > formulas
    # Export brew formulas to the formulas file.
    brew install $(cat formulas)
    ```

### :floppy_disk: Apt Packages

Apt package names are manually backed up to the [`packages` file][13].

The `packages` install may also be manually ran by running the following commands:

=== "Task"
    ```bash
    # Install apt packages from the packages file.
    task apt
    ```
=== "Manual"
    ```bash
    # Install apt packages from the packages file.
    sudo apt install $(cat packages)
    ```

## Dotfiles

[Symbolic links][15] are created from the home directory to the repo so that when the dotfiles are updated, the repo
sees the updates and the changes can be committed to the remote repo.

The `reload` alias, located in [`.bash_aliases`][16] is used to reload the dotfiles in the current shell and upload the
messageless dotfile changes to the remote repo.

### Workflow

1. Make changes to a dotfiles, such as `.bash_aliases`.
2. Reload the dotfiles by using the `reload` alias.

### `.bash*` Files

The default Ubuntu distro both the `.bashrc` and `.bash_aliases` files to separate the profile settings from the aliases.
This same concept is used to separate aliases, functions, exports, and completions.

| File name           | Description                                         |
|---------------------|-----------------------------------------------------|
| `.bash_aliases`     | A list of bash aliases                              |
| `.bash_completions` | A list of bash completions                          | 
| `.bash_exports`     | A list of bash exports, such as `PATH`              |
| `.bash_functions`   | A list of bash functions, such as `mkcdir`          |
| `.bashrc`           | The main bash file that loads all other bash files  |

Common aliases and functions that I like to use are `upgrate`, `reload`, `up`, and `mkcdir`.

!!! note
    The bash dotfiles check that some applications are installed before loading some aliases and functions to ensure
    that the aliases and functions still work. E.g. `mc` for `alias mv='mc mv'`.

## Config Files

Config files are stored in the [`.config` repo directory][17] and linked to the `~/.config/` directory.

Use the following command to manually link other `.config` files.

```shell title="From the repo directory"
ln -snf "$(pwd)/.config/gh/config.yml" "${HOME}/.config/gh/config.yml"
```

```shell title="List the directory to ensure that the link was created properly."
ls -la ~/.config/gh
total 12
drwxr-xr-x 2 ubuntu ubuntu 4096 Jul 24 22:40 .
drwxr-xr-x 4 ubuntu ubuntu 4096 Jul 24 22:40 ..
lrwxrwxrwx 1 ubuntu ubuntu   62 Jul 24 22:40 config.yml -> /home/ubuntu/git/nicholaswilde/dotfiles2/.config/gh/config.yml
```

See the [configuration page][./configuration.md] for how to add these files to the [`Taskfile.yaml` file][18].

[1]: https://brew.sh/
[2]: https://formulae.brew.sh/formula/
[3]: https://github.com/Homebrew/brew/issues/7857
[4]: https://taskfile.dev/
[5]: https://github.com/lastpass/lastpass-cli
[6]: https://www.lastpass.com/
[7]: https://github.com/nicholaswilde/dotfiles2/blob/main/formulas
[8]: https://docs.github.com/en/get-started/getting-started-with-git/about-remote-repositories#cloning-with-ssh-urls
[9]: https://keyserver.ubuntu.com/
[10]: https://support.lastpass.com/help/add-a-new-note
[11]: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/about-ssh
[12]: https://packages.ubuntu.com/kinetic/ssh-import-id
[13]: https://github.com/nicholaswilde/dotfiles2/blob/main/packages
[14]: https://packages.ubuntu.com/kinetic/build-essential
[15]: https://www.futurelearn.com/info/courses/linux-for-bioinformatics/0/steps/201767
[16]: https://github.com/nicholaswilde/dotfiles2/blob/main/.bash_aliases
[17]: https://github.com/nicholaswilde/dotfiles2/tree/main/.config
[18]: https://github.com/nicholaswilde/dotfiles2/blob/main/Taskfile.yaml
