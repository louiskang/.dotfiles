if [[ "$(uname 2> /dev/null)" != "Linux" ]]; then
  source "$HOME/.dotfiles/zshrc_macos"
fi

# Confirm file delete
function rmls() {

	ls -A "$@";
	echo -n "remove file(s) (y/n)? ";
	read a;
	if [[ "$a" == "y" ]]; then
	  \rm "$@"
	fi

}

function pdfoutline() {
  for file in "$@"
  gs -o "${file%.*}-outlined.pdf" -dNoOutputFonts -sDEVICE=pdfwrite "$file"
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
. /opt/intel/oneapi/setvars.sh
#. /opt/intel/oneapi/mkl/latest/env/vars.sh
#. /opt/intel/oneapi/compiler/latest/env/vars.sh
