#! /bin/bash

# Download go from google
wget https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz

# Install tarball
sudo tar -C /usr/local -xzf go1.15.3.linux-amd64.tar.gz

# export GO to path
export PATH=$PATH:/usr/local/go/bin

# check version 
go version
