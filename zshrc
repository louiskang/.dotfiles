# Confirm file delete
function rmls() {

	ls -AGh $@;
	echo -n "remove file(s) (y/n)? ";
	read a;
	if [[ "$a" == "y" ]]; then
	  \rm $@
	fi

}

alias mv='mv -i'
alias ls='ls -Gh'
alias rm='rmls'

