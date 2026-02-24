# ZSH CLI Companion
# 
# https://github.com/kamil-cy/zsh-cli-companion
# v1.0.0

# MIT License

# Copyright (c) 2026 Kamil Cyganowski

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

get_commands_file() {
    local DEBUG=false
    local filename="$1"
    shift
    local dirs=()
    [ "$DEBUG" = "true" ] && echo "DEBUG filename= $filename" >&2

    for arg in "$@"; do
        [ "$DEBUG" = "true" ] && echo "DEBUG dirs.append= $arg" >&2
        if [ "$arg" = ":TRAVERSE_UP:" ]; then
            local d="$PWD"
            while [ "$d" != "/" ]; do
                dirs+=("$d")
                d="$(dirname "$d")"
            done
            dirs+=("/")
        else
            dirs+=("$arg")
        fi
    done
    [ "$DEBUG" = "true" ] && echo "DEBUG dirs= $dirs" >&2

    for dir in "${dirs[@]}"; do
        local candidate="$dir/$filename"
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    echo "Please create $filename in at least one place:" >&2
    for p in "${filename_seek_paths[@]}"; do
        echo "  - $p" | sed "s|:TRAVERSE_UP:|$PWD (or any parent directory)|" >&2
    done
    return 1
}


cli-companion-widget() {
    [[ -v DISABLE_CLI_COMPANION_WIDGET ]] && zle .accept-line && return 0
    local DEBUG=false
    local filename=".commands.sh"
    [[ -v CLI_COMPANION_WIDGET_COMMANDS_FILENAME ]] && filename=$CLI_COMPANION_WIDGET_COMMANDS_FILENAME
    local -a filename_seek_paths=(':TRAVERSE_UP:' $HOME '/dev/shm')
    [[ -v CLI_COMPANION_WIDGET_FILENAME_SEEK_PATHS ]] && filename_seek_paths=$CLI_COMPANION_WIDGET_FILENAME_SEEK_PATHS
    local file="$(get_commands_file "$filename" ${filename_seek_paths[@]})"
    [ -z "$file" ] && return 1
    local -a files=($file)
    [ "$DEBUG" = "true" ] && echo "DEBUG file=($file)"
    grep '^[[:space:]]*!' "$file" \
    | while IFS= read -r line; do
        case "$line" in
            '!'*=*)  # for `!env_name="env_value"  # optional comment`
                key="${line%%=*}"                     # extract key name with !
                val="${line#*=}"                      # extract value
                val="${val%%#*}"                      # remove comment
                val="${val%"${val##*[![:space:]]}"}"  # remove spaces between comment and quotation
                [ "$DEBUG" = "true" ] && echo "DEBUG val=($val)"
                val="${val%\'}"                       # remove quotations at the beginning
                val="${val#\'}"                       # remove quotations at the end
                val="${val%\"}"                       # remove quotations at the beginning
                val="${val#\"}"                       # remove quotations at the end
                key="${key#!}"                        # remove ! from key name
                export "$key=$val"
                ;;
            '!append '*)  # for `!append path_to_file  # optional comment`
                src="${line#*!append }"               # remove '!append '
                src="${src%%#*}"                      # remove comment
                src="${src%"${src##*[![:space:]]}"}"  # remove spaces between comment and quotation
                case "$src" in
                    \"*\") src="${src:1:-1}" ;;
                    \'*\') src="${src:1:-1}" ;;
                esac
                [ "$DEBUG" = "true" ] && echo "DEBUG parsing file: $src"

                [ -f "$src" ] && files+=("$src")
                ;;
        esac
    done

    declare -A finders
    finders[fzf]="fzf --ansi --height 40% --reverse --border"
    finders[sk]="sk --ansi --height 40% --reverse --border"
    finders[gum]="gum choose"
    local -a compatible_finders=(fzf sk gum)
    local finder=""
    for cmd in $compatible_finders; do
        if [[ -n ${commands[$cmd]} ]]; then
            finder=$finders[$cmd]
            [ "$DEBUG" = "true" ] && echo "DEBUG cmd($cmd) finder($finder)"
            break
        fi
    done
    if [ -z "$finder" ]; then
        echo "Please install at least one pipe compatible finder:"
        for p in "${compatible_finders[@]}"; do
            echo "  - $p"
        done
        return 1
    fi
    [[ -v CLI_COMPANION_WIDGET_FINDER ]] && finder=$finders[$CLI_COMPANION_WIDGET_FINDER]
    [[ -v CLI_COMPANION_WIDGET_FINDER_CMD ]] && finder=$CLI_COMPANION_WIDGET_FINDER_CMD
    local finder_cmd=(${=finder})

    declare -A highlighters
    highlighters[cat]="cat"
    highlighters[batcat]="batcat --color=always --language=sh --style=plain"
    highlighters[highlight]="highlight -O ansi --syntax=sh"
    local -a compatible_highlighters=(highlight batcat)
    local highlighter=""
    for cmd in $compatible_highlighters; do
        if [[ -n ${commands[$cmd]} ]]; then
            highlighter=$highlighters[$cmd]
            [ "$DEBUG" = "true" ] && echo "DEBUG cmd($cmd) highlighter($highlighter)"
            break
        fi
    done
    if [ -z "$highlighter" ]; then
        highlighter=$highlighters[cat]
        echo "Hint: you can install at least one pipe compatible color highlighter:"
        for p in "${compatible_highlighters[@]}"; do
            echo "  - $p"
        done
    fi
    [[ -v CLI_COMPANION_WIDGET_HIGHLIGHTER ]] && highlighter=$highlighters[$CLI_COMPANION_WIDGET_HIGHLIGHTER]
    [[ -v CLI_COMPANION_WIDGET_HIGHLIGHTER_CMD ]] && highlighter=$CLI_COMPANION_WIDGET_HIGHLIGHTER_CMD
    local highlighter_cmd=(${=highlighter})

    local cmd_sep="   "
    [[ -v CLI_COMPANION_COMMAND_BEGIN_SEPARATOR ]] && cmd_sep=$CLI_COMPANION_COMMAND_BEGIN_SEPARATOR
    [ "$DEBUG" = "true" ] && echo "DEBUG separator=($cmd_sep)"

    local selected=$(
        grep -h -vE '^\s*$|^\s*#|^\s*!' -- "${files[@]}" \
        | grep -v '^[[:space:]]*[a-zA-Z_]*=' \
        | $highlighter_cmd \
        | awk -v sep="$cmd_sep" '{
            pos = index($0, sep)
            if (pos) {
                left = substr($0, 1, pos + length(sep) - 1)
                right = substr($0, pos + length(sep))
                gsub(/\033\[[0-9;]*m/, "", left)
                printf "\033[90m%s\033[0m%s\n", left, right
            } else {
                print
            }
            }' \
        | nl -n rz -w4 -s" " \
        | $finder_cmd
    )
    BUFFER=$(
        echo "$selected" \
        | sed 's/^[0-9]* //' \
        | sed 's/[[:space:]]*#.*//' \
        | sed 's/[[:space:]]*$//' \
        | sed "s/$cmd_sep/§§§/; s/^[^§]*§§§//"
    )
    CURSOR=${#BUFFER}
    zle reset-prompt
}
zle -N cli-companion-widget
bindkey '^E' cli-companion-widget
