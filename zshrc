if [[ "$(uname 2> /dev/null)" != "Linux" ]]; then
  source "$HOME/.dotfiles/zshrc_macos"
fi

# Confirm file delete
function rmls() {

	ls -A "$@";
	echo -n "remove file(s)? [y/n] ";
	read a;
	if [[ "$a" == "y" ]]; then
	  \rm "$@"
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


function phy-fix-waveforms () {
  
  (echo "import numpy as np" ; \
    echo "np.load('_phy_spikes_subset.waveforms.npy')") | python

}


alias mv='mv -i'
alias rm='rmls'

if [[ "$(uname 2> /dev/null)" == "Linux" ]]; then
    alias ls='ls --color=auto -h'
else
    alias ls='ls -Gh'
fi
alias ll='ls -l'
alias la='ls -a'


# username@hostname directory #
PROMPT='%F{green}%n@%m %F{blue}%1~ %f%# '


# binds up and down to partial history search
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# used by karabiner-elements
WORDCHARS=''
bindkey '^[e' redo
bindkey '^[^B' vi-backward-blank-word
bindkey '^[^F' vi-forward-blank-word
bindkey '^U' backward-kill-line
#bindkey "^[[H"  beginning-of-line
#bindkey "^[[F"  end-of-line


# setup Intel oneAPI environment
#source /opt/intel/oneapi/setvars.sh
source /opt/intel/oneapi/mkl/latest/env/vars.sh
#source /opt/intel/oneapi/compiler/latest/env/vars.sh
