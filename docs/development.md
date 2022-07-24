# Development

## :fontawesome-brands-docker: Docker

### :fontawesome-brands-ubuntu: Ubuntu Server Image

The [ubuntu-server image][1] may be used to help develop the repo.

=== "Task"
    ```shell
    task venv
    ```
=== "Manual"
    ```shell
    docker run -it --rm --entrypoint /bin/bash -u ubuntu -w /home/ubuntu nicholaswilde/ubuntu-server:22.10
    ```

The default username and password for the `ubuntu-server` image is as follows:

| Username  | Password  |
|-----------|-----------|
| ubuntu    | ubuntu    |

!!! note
    At the time of this writing, the `ubuntu-server` image only has tags for `20.10`.  

### :fontawesome-brands-ubuntu: Official Ubuntu Image

The official [Ubuntu image][3] may also be used to test the repo.

```shell
docker run -it --rm --entrypoint /bin/bash ubuntu:22.10
```

```shell title="From inside Docker"
(
  export DEBIAN_FRONTEND=noninteractive
  apt update
  apt install -y ubuntu-server sudo
  adduser ubuntu
  echo "ubuntu:ubuntu" | chpasswd
  usermod -aG sudo ubuntu
  su ubuntu
  cd ~
)
```

!!! note
    The above changes are lost once the docker container is exited.

## :fontawesome-solid-book-open-reader: MkDocs & MkDocs Material

An [MkDocs][2] server may be used to serve the `dotfiles2` site. [MkDocs Material][3] is also required to render the server
properly.

=== "Task"
    ```shell
    task serve
    ```
=== "Manual"
    ```shell
    mkdocs serve
    ```

[1]: https://hub.docker.com/r/nicholaswilde/ubuntu-server/tags
[2]: https://www.mkdocs.org/
[3]: https://squidfunk.github.io/mkdocs-material/
