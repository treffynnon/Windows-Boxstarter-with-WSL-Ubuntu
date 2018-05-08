#! /usr/bin/env bash
if [ "$1" != "$SSH_AUTH_SOCK" ]; then
  echo "Environment patching:"
  colordiff -a <(echo "$SSH_AUTH_SOCK") <(echo "$1")
  export SSH_AUTH_SOCK="$1"
fi