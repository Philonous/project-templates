#!/usr/bin/env bash

set -euo pipefail

## Constants / script configuration
###########################

# Use git to fetch templates
templates_repository="https://github.com/Philonous/project-templates.git"
# Alternatively use local folder
# templates="$HOME/templates"

default_template="haskell/simple"

# Comment this out if you don't want to set a remote repository
# "%s" is replaced with the project name
remote_template="git@github.com:/Philonous/%s.git"

## Helpers
###########################

# Make sure we clean up temporary files/directories when the script exits
declare -a tmpfiles

cleanup () {
  for f in "${tmpfiles[@]}"; do
    rm -rf "$f"
  done
}

trap cleanup EXIT

# Check that necessary tools exist
if ! command -v mustache &>/dev/null; then
  if command -v nix-shell &>/dev/null; then
    exec nix-shell -p 'git' -p 'mustache-go' --run "$0 $*"
  else
    echo >&2 "You need to install the mustache cli programme (e.g. ruby-mustache on ubuntu, mustache-go on nixos)"
    exit 1
  fi
fi

## Configuration
###########################

project="$1"

echo >&2 "Project name is $project"

if [[ -e "$project" ]]; then
  echo >&2 "$project already exists"
  exit 1
fi

author="$(git config --get user.name)"
email="$(git config --get user.email)"
echo >&2 "Using author \"$author\" ($email)"

lts_url="$(curl --silent --write-out '%{redirect_url}' https://www.stackage.org/lts)"
lts="${lts_url#https://www.stackage.org/}"
echo "Using resolver $lts"

## Fetch template
###########################

if [[ -n ${templates_repository:-""} ]]; then
  templates="$(realpath "$(mktemp -d "templates-XXXX")")"
  tmpfiles+=( "$templates" )

  git clone -q "$templates_repository" --depth 1 "$templates"
fi

if [[ -n ${2:-""} ]]; then
  template="$templates/$2"
else
  template="$templates/$default_template"
fi

if ! [[ -d $template ]]; then
  echo >&2 "Template: $template does not exist or is not a directory"
  exit 1
fi

## Create project
###########################

cp -r "$template" "./$project"

cd "$project"

configfile=$(mktemp "haskell-make-project-XXXX")
tmpfiles+=( "$configfile" )

cat > "$configfile" <<EOF
---
author: "$author"
email: "$email"
desc: "An example project"
name: "$project"
stack-resolver: "$lts"
EOF

## Instantiate mustache templates
###########################

find . -iname '*.mustache' -type f -print0 | while read -d $'\0' -r template; do
  mustache "$configfile" "$template" > "${template%.mustache}"
  rm "$template"
done

## Git
###########################
git init >/dev/null
git add ./*
git commit -m "Initial commit" >/dev/null

if [[ -n ${remote_template:=""} ]]; then
  # shellcheck disable=SC2059
  git remote add origin "$(printf "$remote_template" "$project")"
fi

## Direnv
###########################

if (command -v direnv &>/dev/null); then
  cat > .envrc <<EOF
use nix
export NIX_PATH="nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs-unstable"

# Stop problems with certificates that can't be found
unset NIX_SSL_CERT_FILE
unset SSL_CERT_FILE
EOF
  direnv allow

else
  echo >&2 "direnv not found, skipping initialization"
fi
