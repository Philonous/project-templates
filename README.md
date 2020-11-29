# Project Templates

This repository contains templates for quickly setting up projects

### create-project.sh

A script that creates a new project in the current directory and instantiates it.

It's meant to be simple and readable. Instead of trying to accomodate

#### Requirements

* git
* mustache (e.g. go-mustache)
* nix/direnv (optional)
Creation of shell.nix and .envrc will be skipped if `direnv` is not in path.

#### Usage

```
bash create-project.sh {project-name} [template-subfolder]
```

Example

```
bash create-project.sh frobnicator haskell/simple
```

#### Configuration

* You "configure" the script by modifying it
* By default is refers to templates in this repository

* It tries to guess some information via `git config --get user.name` and `git config --get user.email`
* It fetches the latest stack lts

Additional changes can be done manually to the newly created project

## Templates

### haskell/simple

A simple haskell project

#### Requirements
* stack
* make (optional)
