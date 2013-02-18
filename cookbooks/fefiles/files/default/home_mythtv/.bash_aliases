alias ll="clear;ls -l --color=yes|more"
alias lt="clear;ls -lt --color=yes|more"
alias la="clear;ls -la --color=yes|more"
alias h="history"
alias c="clear"
alias r="resize"
alias m="multixterm"
alias alias2="declare -f | tail -70|less"
alias mrestart="sudo service mythtv-backend restart"
alias mstart="sudo service mythtv-backend start"
alias mstop="sudo service mythtv-backend stop"
alias mbrestart="sudo initctl restart mythtv-backend"
alias mbstart="sudo initctl start mythtv-backend"
alias mbstop="sudo initctl stop mythtv-backend"
alias iphones="avahi-browse -r -k _touch-remote._tcp"

#Print decimal given hex
dec () {
  for i in $*;do
   echo Hex:$i = Decimal: $((0x$i))
  done
}

aptsearch () {
 aptitude search $*
}

aptshow () {
 aptitude show $*
}


aptlist () {
 dpkg-query -L $*
}

aptlast () {
  (cd /var/log; cat dpkg.log dpkg.log.1 ; zcat `ls -t dpkg.log.*.gz`) | egrep ' install | remove '
}

