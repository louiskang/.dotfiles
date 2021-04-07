# Confirm file delete
function rmls() {

	ls -A $@;
	echo -n "remove file(s) (y/n)? ";
	read a;
	if [[ "$a" == "y" ]]; then
	  \rm $@
	fi

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
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
