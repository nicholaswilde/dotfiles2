# dotfiles2
[![task](https://img.shields.io/badge/task-enabled-brightgreen?logo=task&logoColor=white&style=for-the-badge)](https://taskfile.dev/)

My Debian based dotfiles.

## :rocket: TL;DR

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicholaswilde/dotfiles2/main/scripts/init.sh)"
cd ~/git/nicholaswilde/dotfiles2
task dotfiles
```

## :information_source: About

> Dotfiles are used to customize your system. The "dotfiles" name is derived from the configuration files in Unix-like
> systems that start with a dot (e.g. .bash_profile and .gitconfig). For normal users, this indicates these are not
> regular documents, and by default are hidden in directory listings. For power users, however, they are a core tool
> belt. - [webpro][3]

This repo is used to manage my dotfiles by automating the backup and installation of them. This repo also backups a list
of Homebrew formulas and apt packages that can be easily redeployed. The repo also uses a ubuntu-server Docker image
as a virtual environment for testing.

## :bulb: Inspiration

Inspiration for this repository has been taken from [jessfraz/dotfiles][2].

## :scales:​ License

​[Apache 2.0 License](../LICENSE)

## :pencil:​ Author

​This project was started in 2022 by [Nicholas Wilde][1].

[1]: https://github.com/nicholaswilde/
[2]: https://github.com/jessfraz/dotfiles
[3]: https://www.webpro.nl/articles/getting-started-with-dotfiles#introduction
