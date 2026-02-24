# ZSH CLI Companion

A lightweight terminal‑based tool for storing and reusing custom shell commands. It lets you build your own command library without unnecessary dependencies, a GUI or complicated configuration.

- [Instalation](#instalation)
  - [Oh My Zsh](#oh-my-zsh)
  - [Manual](#manual-git-clone)
- [Description](#description)
- [What can it do?](#what-can-it-do)
- [Advantages](#advantages)
- [Who is it for?](#who-is-it-for)
- [`.commands.sh` file structure](#commandssh-file-structure)
  - [Commands](#commands)
  - [Control instructions](#control-instructions)
    - [Setting environment variables](#setting-environment-variables)
    - [Including other files](#including-other-files)
- [Usage](#usage)
- [License](#license)

## Instalation

### Oh My Zsh

1. Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`)

```sh
git clone https://github.com/kamil-cy/zsh-cli-companion ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-cli-companion
```

2. Add the plugin to the list of plugins for Oh My Zsh to load (inside `~/.zshrc`):

```sh
plugins=(
    # other plugins...
    zsh-cli-companion
)
```

### Manual (Git Clone)

1. Clone this repository somewhere on your machine. This guide will assume `~/.zsh/zsh-cli-companion`.

```sh
git clone https://github.com/kamil-cy/zsh-cli-companion ~/.zsh/zsh-cli-companion
```

2. Add the following to your `.zshrc`:

```sh
source ~/.zsh/zsh-cli-companion/zsh-cli-companion.zsh
```

3. Start a new terminal session.

## Description

A lightweight FZF‑based tool for storing and reusing your own commands.
It provides a simple way to build your personal command library without unnecessary dependencies, GUIs, or complex configuration.

CLI Companion lets you store and quickly run your custom commands. Commands are saved in a file (by default `.commands.sh`) located in the current working directory (any parent directory) or in your home directory. You manage commands directly by editing the command file, making it easy to add, modify, and organize your personal command library. The tool allows you to browse available entries and execute them directly from the terminal, speeding up your workflow and eliminating the need to remember complex command syntax.

This way, you can create both a global set of commands and project‑specific, local sets tailored to particular environments.

Beginners can learn by exploring ready‑made examples.
Advanced users can build their own library of scripts and commands instead of keeping them scattered in notes.

## What can it do?

- store and organize commands along with your own descriptions and comments
- manage your library easily by editing a single file
- instantly search and insert commands into the terminal using fuzzy finders (`fzf`, `skim`, `gum` — one of them is required)
- execute commands without remembering their syntax
- optionally highlight syntax using external tools (e.g., `batcat`, `highlight`)

## Advantages

- works in a pure ZSH terminal with at least one fuzzy finder
- zero unnecessary dependencies
- simple, transparent structure
- ability to create local per‑project libraries
- quick access to frequently used commands

## Who is it for?

- anyone who wants to keep a personal command library at hand
- developers working across multiple projects
- users who don’t want to memorize long commands
- anyone who likes order in their terminal

## `.commands.sh` file structure

The file contains control instructions and a list of commands.

### Commands

Each command is written on a single line. You decide how to organize them — the tool simply reads and exposes them.

Example:

```sh
[optional categories SEPARATOR] actual command with arguments  # comment
```

### Control instructions

### Setting environment variables

To set an environment variable, prefix its name with `!`, then assign a value with `=` wrapped in `"` or `'`. Example:

```sh
!CLI_COMPANION_WIDGET_FINDER="gum"
```

### Including other files

The `!append` instruction includes another file at the end of the current one, without nested processing of control instructions. Example:

```sh
!append $HOME/.another_commands.sh
```

## Usage

1. Create a `.commands.sh` file in your home or current directory.
2. Add your commands to it.
3. Launch the tool in the terminal using the CTRL+E shortcut.
4. Select a command from the list to insert it into the terminal.

## License<a id="license"></a>

This repository is licensed under the [MIT License](https://github.com/kamil-cy/zsh-cli-companion/blob/main/LICENSE)
