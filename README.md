# Project Templates

This repository contains templates for quickly setting up projects

### create-project.sh

A script to creates a new project in the current directory.

It's meant to be simple and readable and handle common case with as little
hassle as possible

* Do the boring legwork to get a functioning project
* Fill in the most common information using mustache
* Don't bother the user for information if it can be filled in later

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
