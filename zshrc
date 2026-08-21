if [[ "$(uname 2> /dev/null)" != "Linux" ]]; then
  source "$HOME/.dotfiles/zshrc_macos"
fi


# username@hostname directory #
PROMPT='%F{green}%n@%m %F{blue}%1~ %f%# '


# Turn off beep during autocomplete and history
unsetopt BEEP

# Prevent Delete key from closing Terminal
setopt IGNORE_EOF


# binds up and down to partial history search
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# used by karabiner-elements
#WORDCHARS=''
#bindkey '^[e' redo
#bindkey '^[^B' vi-backward-blank-word
#bindkey '^[^F' vi-forward-blank-word
#bindkey '^U' backward-kill-line
#bindkey "^[[H"  beginning-of-line
#bindkey "^[[F"  end-of-line


# Allow alias expansion after sudo
alias sudo='sudo '

# Confirm file delete
function rmls() {

	ls -A "$@";
	echo -n "remove file(s)? [y/n] ";
	read a;
	if [[ "$a" == "y" ]]; then
	  \rm "$@"
	fi

}
alias rm='rmls'

if [[ "$(uname 2> /dev/null)" == "Linux" ]]; then
    alias ls='ls --color=auto -h'
else
    alias ls='ls -Gh'
fi
alias ll='ls -l'
alias la='ls -a'

alias mv='mv -iv'
alias cp='cp -iv'
alias rsync='rsync -rvh --progress'


findn() {
  local pattern="$1"
  local dir="${2:-.}"
  find "$dir" -iname "*${pattern}*" | sort
}



# Usage: send from|to hostname file_or_dir1 [file_or_dir2 ...] [--exclude=pattern ...] [--phy]
#
#   send from HOST f1 [f2 ...]   copy newer $PWD/f1 ... from HOST down to the local machine
#   send to   HOST f1 [f2 ...]   copy newer $PWD/f1 ... from the local machine up to HOST
#
function send () {
 
  local usage='Usage: send from|to hostname file_or_dir1 [file_or_dir2 ...] [--exclude=pattern ...] [--phy]'
 
  local dir=$1
  if [[ "$dir" != from && "$dir" != to ]]; then
    echo "$usage"
    return 1
  fi
  shift
 
  if [[ $# -lt 2 ]]; then
    echo "$usage"
    return 1
  fi
  # "$HOME"/* : $HOME literal, the trailing /* is a pattern on purpose
  if [[ "$PWD" != "$HOME" && "$PWD" != "$HOME"/* ]]; then
    echo 'Current directory is not under $HOME'
    return 1
  fi
 
  # $PWD as the remote host sees it; ~ stays literal for the remote shell to expand
  local pwd host
  if [[ "$1" == experiments || "$1" == buffalo ]]; then
    host=buffalo
    pwd="/Volumes/experiments${PWD#"$HOME"}"
  else
    host=$1
    pwd="~${PWD#"$HOME"}"
  fi
  shift
 
  local args=()
  local extra_excludes=()
  local phy_flag=false
 
  # Separate normal args, excludes, and check for --phy flag
  local arg
  for arg in "$@"; do
    case "$arg" in
      --exclude=*)
        extra_excludes+=("$arg")
        ;;
      --phy)
        phy_flag=true
        ;;
      *)
        args+=("$arg")
        ;;
    esac
  done
 
  if [[ ${#args[@]} -eq 0 ]]; then
    echo "$usage"
    return 1
  fi
 
  # Add phy-related excludes if flag is set
  if $phy_flag; then
    extra_excludes+=(
      "--exclude=*/analyzer"
      "--exclude=*/sorter_output"
      "--exclude=*/analyzer_output"
      "--exclude=*/results"
      "--exclude=*/*.ipynb"
    )
  fi
 
  local flags=( -avh --progress --mkpath --relative )
  # *.riken.jp must stay unquoted -- it is a pattern
  if [[ "$HOST" != *.riken.jp ]]; then
    flags+=( -z )
  fi
  case "$host" in
    akashi)   flags+=( '--rsync-path=/usr/local/bin/rsync' )    ;; # Intel Homebrew
    buffalo)  flags+=( '--rsync-path=/opt/homebrew/bin/rsync' ) ;; # Apple Silicon Homebrew
  esac
 
  local base_excludes=(
    "--exclude=*/.DS_Store"
    "--exclude=*/.*.swp"
    "--exclude=*/.unison"
    "--exclude=*/.ipynb_checkpoints"
    "--exclude=*/.git"
    "--exclude=*/.phy"
  )
 
  # Optional excludes used only for the "y" choice
  local optional_excludes=(
    "--exclude=*/compile.sh"
    "--exclude=*/*.dat"
    "--exclude=*/*.dat.gz"
    "--exclude=*/*.bin"
    "--exclude=*/*.raw"
  )
 
  # Direction-specific pieces: sources, destination, prompt wording
  local files=() dest verb prep
  if [[ "$dir" == from ]]; then
    for arg in "${args[@]}"; do
      files+=( "$host:$pwd/./${arg%/}" )
    done
    dest="$PWD"
    verb=receive
    prep=from
  else
    for arg in "${args[@]}"; do
      files+=( "./${arg%/}" )
    done
    dest="$host:$pwd"
    verb=send
    prep=to
  fi
 
  echo -n "$verb ${args[*]%/} $prep $host:$pwd/ (y/n/all/force)? "
  local a
  read -r a
 
  local cmd=( rsync "${flags[@]}" )
  case "$a" in
    y)
      cmd+=( -u "${base_excludes[@]}" "${optional_excludes[@]}" )
      ;;
    all)
      cmd+=( -u "${base_excludes[@]}" )
      ;;
    force)
      cmd+=( "${base_excludes[@]}" )
      ;;
    *)
      echo 'Terminating without transfer'
      return 0
      ;;
  esac
  cmd+=( "${extra_excludes[@]}" "${files[@]}" "$dest" )
 
  "${cmd[@]}"
}

# Optional: keep the old spellings working
function from () { send from "$@"; }
function to   () { send to   "$@"; }


batchrename() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: batchrename <search> <replace>"
        return 1
    fi

    local search="$1" replace="$2"
    local -a files

    files=($(find . -depth -name "*$search*"))

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files or directories found matching '*$search*'."
        return 0
    fi

    local has_changes=false
    for file in "${files[@]}"; do
        local dir="${file:h}" base="${file:t}"
        local newbase="${base//$search/$replace}"
        if [[ "$base" != "$newbase" ]]; then
            echo "$file -> $dir/$newbase"
            has_changes=true
        fi
    done

    if [[ "$has_changes" == "false" ]]; then
        echo "No files or directories need renaming."
        return 0
    fi

    echo
    read "ans?Rename all of these? (y/N): "

    if [[ "$ans" == "y" ]]; then
        for file in "${files[@]}"; do
            local dir="${file:h}" base="${file:t}"
            local newbase="${base//$search/$replace}"
            local target="$dir/$newbase"
            if [[ "$base" != "$newbase" ]]; then
                if [[ -e "$target" ]]; then
                    echo "Skipping '$file' -> '$target' (target exists!)"
                else
                    \mv "$file" "$target" && echo "renamed '$file' -> '$target'"
                fi
            fi
        done
    else
        echo "Aborted."
    fi
}


function pdfoutline() {
  for file in "$@"
  do
    gs -o "${file%.*}-outlined.pdf" -dNoOutputFonts -sDEVICE=pdfwrite "$file"
  done
}
function pdfocrop() {
  for file in "$@"
  do
    newfile="${file%.*}-crop.pdf"
    gs -o "$newfile" -dNoOutputFonts -sDEVICE=pdfwrite "$file"
    pdfcrop "$newfile" "$newfile"
  done
}
function invertbw() {
  # Example usage:
  # ./invertbw.sh -threshold 10% image1.png image2.png
  #
  threshold="1%"
  
  # Check for the optional threshold flag
  while [[ "$1" == -* ]]; do
    case "$1" in
      -threshold)
        shift
        threshold="$1"
        ;;
    esac
    shift
  done

  # Process each file
  for file in "$@"
  do
    # Ignore files ending in -inverted
    if [[ "$file" == *-inverted.* ]]; then
      echo "Ignoring file: $file"
      continue
    fi
    newfile="${file%.*}-inverted.${file##*.}"
    magick "$file" \( -clone 0 -colorspace HSB -channel g -separate +channel -threshold "$threshold" \) \
      \( -clone 0 -clone 1 -alpha off -compose CopyOpacity -composite -negate \) \
      -delete 1 -compose over -composite "$newfile"
  done
}

# Set standard permissions
function stdmod() {

  find . -perm 777
	echo -n "change permissions to 755 for directories and 644 for files? [y/n] ";
	read a;
	if [[ "$a" == "y" ]]; then
    find . -type d -perm 777 -exec chmod 755 '{}' \;
    find . -type f -perm 777 -exec chmod 644 '{}' \;
	fi

}

# function phy-fix-waveforms () {
#   
#   (echo "import numpy as np" ; \
#     echo "np.load('_phy_spikes_subset.waveforms.npy')") | python
# 
# }


# setup Intel oneAPI environment
#source /opt/intel/oneapi/setvars.sh
#source /opt/intel/oneapi/mkl/latest/env/vars.sh
#source /opt/intel/oneapi/compiler/latest/env/vars.sh
