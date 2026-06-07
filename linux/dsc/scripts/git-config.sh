#!/usr/bin/env bash

read -rp "Enter your git username: " username
read -rp "Enter your git email: " email
git config --global user.name $username
git config --global user.email $email
