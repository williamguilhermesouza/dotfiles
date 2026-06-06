# build with docker build . -t dotfiles-test
# run with docker run -it --rm dotfiles-test
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    sudo

WORKDIR /dotfiles

COPY . .

CMD ["/bin/bash"]
