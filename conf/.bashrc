# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

###########################
#	USER DEFINED	  #
###########################

####### PROMPT ############

make_prompt() {
    blk_bck="\[\e[48;5;232m\]"
    yel_bck="\[\e[48;5;220m\]"
    red_bck="\[\e[48;5;160m\]"
    wht_bck="\[\e[48;5;255m\]"
    yel_txt="\[\e[1;38;5;220m\]"
    blk_txt="\[\e[1;38;5;232m\]"
    gry_txt="\[\e[1;38;5;238m\]"
    red_txt="\[\e[1;38;5;160m\]"
    blu_txt="\[\e[1;38;5;39m\]"
    rst="\[\e[0m\]"

    #UTF
    angle_left="\u250f"
    angle_right="\u2517"
    line="\u2501"
    sep="${gry_txt}${line}\u2589${line}${line}${rst}"
    dir="${rst}${blu_txt}\\W${rst}"
    host="${rst}${blu_txt}\\h${rst}"
    user="${rst}${blu_txt}\\u${rst}"
    cmd="${rst}${blu_txt}\\!${rst}"
    root="${rst}${blu_txt}\\$"

    if [ -n "$(pgrep nc$)" ]; then
        ncvals="nc:"
        for i in $(pgrep -a nc$ | rev | cut -d " " -f 1 | rev); do
            ncvals="$ncvals $i"
        done
    fi

    if [ -n "$(pgrep -f http.server | grep -v sudo)" ]; then
        phsvals="phs:"
        for i in $(pgrep -af http.server | grep -v sudo | rev | cut -d " " -f 1 | rev); do
            if [ "$i" == "http.server" ]; then
                i="8000"
            fi
            phsvals="$phsvals $i"
        done
    fi

    alert=""
    if [ -f "/tmp/.sshspy_notif" ]; then
        alert="${yel_txt}!${rst}"
    fi

    if [ $(tput cols) -gt 60 ]; then

        echo -e "\n${gry_txt}${angle_left}${line}${dir}${sep}${user}${sep}${host}${sep}${cmd}${sep}${gry_txt}[${blu_txt} ${ncvals}| ${phvals}${gry_txt}]${rst}${sep}${gry_txt}[${alert}${gry_txt}]${rst}"
        echo -e "${gry_txt}${angle_right}${gry_txt}${line}${line}${gry_txt}[${root}${gry_txt}]${rst} "

    elif [ $(tput cols) -gt 30 ]; then

        echo -e "${user}[${cmd}]> "

    else
        echo =e "> "
    fi

}

build_prompt() {

    export PS1=$(make_prompt)
}


PROMPT_COMMAND=build_prompt

LS_COLORS="rs=0:di=01;34;1;255:ln=01;36:mh=00:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=3744:ex=01;38;5;184:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"


###### ALIAS ######

alias c="clear"
alias ls-full="ls -la --time-style=full-iso"
alias ll="ls -la"
alias nmap-standard="sudo nmap -sC -sV -oA initial "
alias nmap-full="sudo nmap -sV -p- -oA full "
alias nmap-udp="sudo nmap -sU -oA udp "
alias gob="gobuster dir -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt -u "
alias gobphp="gobuster dir -w /usr/share/dirbuster/wordlists/directory-list-2.3-medium.txt -x .php -u "
alias ghidra="/opt/ghidra_9.1.1/ghidraRun"
alias ss="searchsploit "
alias phs="sudo python3 -m http.server "
alias http_srv="(cd /opt/scripts && phs 80)"
alias htbconnect="sudo openvpn ~/htb/cerbersec.ovpn"
alias cdhtb="cd ~/htb/boxes"
alias johnrock="john --wordlist=/usr/share/wordlists/rockyou.txt "
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'
alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])"'
alias htbrecon='/opt/HTBRecon/htbrecon.py'

###### FUNCTIONS #######

function nmap-init {

    nmap-fulltcp $1 >/dev/null 2>&1 &
    nmap-udp $1 >/dev/null 2>&1 &
    nmap-standard $1
}

function nmap-fulltcp {

    nmap -p- $1 -oA full
}

function nmap-udp {

    nmap -sU $1 -oA udp
}

function nmap-standard {

    nmap -sC -sV $1 -oA initial
}

function get-php-reverse {

    SOURCE_FILE="/usr/share/laudanum/php/php-reverse-shell.php"

    cp $SOURCE_FILE .
    sed -i "s/#CHANGEME_IP/\'$1\'/g" php-reverse-shell.php
    sed -i "s/#CHANGEME_PORT/$2/g" php-reverse-shell.php
}


# JAVA JDK 11 for Ghidra
export PATH=/opt/jdk-11/bin:$PATH
