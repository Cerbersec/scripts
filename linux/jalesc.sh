#!/bin/bash
#Created by: @kindredsec

C_RESET='\033[0m'
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_WHITE='\033[1;37m'
C_RESET_SED='\\033[0m'
C_RED_SED='\\033[1;31m'
C_GREEN_SED='\\033[1;32m'
C_YELLOW_SED='\\033[1;33m'
C_WHITE_SED='\\033[1;37m'

function print_err {
    echo -e "${C_RED}[-]${C_RESET} $1"
	echo ""
}

function print_notif {
    echo -e "${C_YELLOW}[!]${C_RESET} $1"
	echo ""
}

function print_success {
    echo -e "${C_GREEN}[+]${C_RESET} $1"
	echo ""
}

function note_highlight {
    echo ""
    echo -e "(${C_YELLOW}highlight${C_RESET} = $1)"
    echo ""
}

echo "#################################################"
echo "#          SECTION: Basic System Info           #"
echo "#################################################"
echo ""
echo "----------------------------"
echo -e "${C_WHITE}Kernel Info${C_RESET}"
echo "----------------------------"
echo ""
echo -e "${C_WHITE}Kernel Release:${C_RESET} $(uname -r)"
kernelver=$(uname -v)
kernelyear=$(echo "$kernelver" | rev | cut -d " " -f 1 | rev)
curryear=$(date +%Y)
if [ $(expr $curryear - $kernelyear) -ge 2 ]; then
    	kernelver=$(echo "$kernelver" | sed "s/${kernelyear}/${C_YELLOW_SED}${kernelyear}${C_RESET_SED}/g")
	echo -e "${C_WHITE}Kernel Version:${C_RESET} $kernelver"
	note_highlight "Last kernel update was over 2 years ago"
else
	echo -e "${C_WHITE}Kernel Version:${C_RESET} $kernelver"
	echo ""
fi
echo "----------------------------"
echo -e "${C_WHITE}Disk Usage${C_RESET}"
echo "----------------------------"
echo ""
df -h
echo ""
echo ""

	
echo "#################################################"
echo "#              SECTION: Networking              #"
echo "#################################################"
echo ""

echo "----------------------------"
echo -e "${C_WHITE}INTERFACE IP ADDRESSES${C_RESET}"
echo "----------------------------"
echo ""
if [ -n "$(which ifconfig 2>/dev/null)" ]; then
    ifout=$(ifconfig)
    if [ $(echo "$ifout" | grep -c "inet addr:") -gt 0 ]; then
    	inetaddrs=$(echo "$ifout" | grep -o "inet addr:[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}")
    else
    	inetaddrs=$(echo "$ifout" | grep -o "inet [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}")
    fi
		
else
    ifout=$(ip addr show)
    inetaddrs=$(echo "$ifout" | grep -o "inet [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}")
fi

while read -r addr; do
    ifout=$(echo "$ifout" | sed "s/${addr}/${C_YELLOW_SED}${addr}${C_RESET_SED}/g")
done <<< "$inetaddrs"
echo -e "$ifout"
note_highlight "ipv4 addresses"

echo "----------------------------"
echo -e "${C_WHITE}ARP CACHE${C_RESET}"
echo "----------------------------"
echo ""
cat /proc/net/arp
echo ""

echo "----------------------------"
echo -e "${C_WHITE}LISTENING SOCKETS${C_RESET}"
echo "----------------------------"
echo ""
netstat -auntp 2>/dev/null | egrep "(Proto|LISTEN|udp)"
echo ""

echo "----------------------------"
echo -e "${C_WHITE}ESTABLISHED CONNECTIONS${C_RESET}"
echo "----------------------------"
echo ""
netstat -auntp 2>/dev/null | egrep -v "(LISTEN|udp)"
echo ""

echo "----------------------------"
echo -e "${C_WHITE}DNS AND HOSTNAMES${C_RESET}"
echo "----------------------------"
echo ""
echo -e "${C_WHITE}Our Hostname:${C_RESET} $(hostname)"
echo ""
echo -e "${C_WHITE}Configured name servers:${C_RESET}"
echo "$(grep "nameserver" /etc/resolv.conf 2>/dev/null)"
echo ""
echo -e "${C_WHITE}Mappings configured in /etc/hosts:${C_RESET}"
echo "$(egrep -v "#" /etc/hosts 2>/dev/null | sed '/^$/d')"
echo ""


echo "#################################################"
echo "#          SECTION: Users and Groups            #"
echo "#################################################"
echo ""

echo "----------------------------"
echo -e "${C_WHITE}CURRENT USER${C_RESET}"
echo "----------------------------"
echo ""
echo -e "${C_WHITE}USER NAME:${C_RESET} $(whoami)"
echo -e "${C_WHITE}GROUPS:${C_RESET} $(groups)"
echo -e "${C_WHITE}UIDs/GIDs:${C_RESET} $(id)"
echo ""


echo "----------------------------"
echo -e "${C_WHITE}PASSWD OUTPUT${C_RESET}"
echo "----------------------------"
echo ""
passwd=$(cat /etc/passwd)
interactiveUsers=$(echo "$passwd" | egrep "(/bin/bash|/bin/csh|/bin/ksh|/bin/sh|/bin/tcsh|/bin/zsh)")
while read -r line; do
    line=$(echo "$line" | sed "s/\//\\\\\//g")
    passwd=$(echo "$passwd" | sed "s/${line}/${C_YELLOW_SED}${line}${C_RESET_SED}/g")
done <<< "$interactiveUsers"
echo -e "$passwd"
note_highlight "users with an interactive shell"

echo "----------------------------"
echo -e "${C_WHITE}POPULATED GROUPS${C_RESET}"
echo "----------------------------"
echo ""
out=$(cat /etc/group)
echo "GROUP:GRPPASSWD:GID:MEMBERS"
while read -r group; do
	if [ -n "$( echo "$group" | cut -d ":" -f 4)" ]; then
		echo "$group"
	fi
done <<< "$out"
echo ""


echo "----------------------------"
echo -e "${C_WHITE}RECENT USER SESSIONS${C_RESET}"
echo "----------------------------"
echo ""
if [ -n "$(which last 2>/dev/null)" ] && [ -f "/var/log/wtmp" ]; then
    last -n 10 | grep -v "wtmp begins"
else
    print_err "The \'last\' utility is not available on this system. Skipping . . ."
fi
echo ""

echo "----------------------------"
echo -e "${C_WHITE}RECENT SSH LOGINS${C_RESET}"
echo "----------------------------"
echo ""
if [ -r "/var/log/secure" ]; then
    logFile="/var/log/secure"
elif [ -r "/var/log/auth.log" ]; then
    logFile="/var/log/auth.log"
else
    logFile="NOPERMS"
fi

if [ "$logFile" == "NOPERMS" ]; then
    print_err "Insufficient permissions for reading authentication logs. Skipping . . ."
    echo ""
else
    sshhist=$(grep -m 15 "Accepted" $logFile)
    if [ -z "$sshhist" ]; then
	print_notif "No presence of any SSH authentication history . . . "
    	echo ""
    else 
    	users=$(echo "$sshhist" | grep -o "for .* from" | cut -d " " -f 2 | sort | uniq)
    	while read -r user; do
        	sshhist=$(echo "$sshhist" | sed "s/${user}/${C_YELLOW_SED}${user}${C_RESET_SED}/g")
    	done <<< "$users"
    	echo -e "$sshhist"
    	note_highlight "accounts trying to authenticate"
    fi
fi

echo "----------------------------"
echo -e "${C_WHITE}HOME DIRECTORIES${C_RESET}"
echo "----------------------------"
echo ""
homedirs=$(ls /home/)
if [ -z "$homedirs" ]; then
	print_notif "The /home directory appears to be empty . . ."
	echo ""
else
	homedirs=$(ls -lh /home)
	readables=$(find /home/ -maxdepth 1 -type d -readable | tail -n +2)
	echo -e "${C_WHITE}/home${C_RESET}"
	echo -e "$homedirs"
	echo ""

	while read -r dir; do
    	echo -e "${C_WHITE}${dir}${C_RESET}"
    	ls -lah $dir
    	echo ""
	done <<< "$readables"
	echo ""
fi

echo "----------------------------"
echo -e "${C_WHITE}SUDOERS${C_RESET}"
echo "----------------------------"
echo ""
if [ -r "/etc/sudoers" ]; then
	print_success "/etc/sudoers file is accessible, printing contents . . ."
	cat /etc/sudoers
	echo ""
else
	print_notif "This could take a few moments . . ."
	saasFiles=$(find / -not -path "/proc/*" -not -path "/sys/*" -not -path "/dev/*" -not -path "/snap/*" -not -path "/usr/lib/*" -name ".sudo_as_admin_successful" 2>/dev/null)
	if [ -z "$saasFiles" ]; then
		print_notif "Could not verify any sudo privileges. You may want to manually check your current account with 'sudo -L'."	
	else
		while read -r saas_file; do
			user=$(stat -c '%U' $saas_file)
			echo -e "${C_YELLOW}${user}${C_RESET} has a history of using sudo! (Located ${saas_file})"
			echo ""
		done <<< "$saasFiles"
	fi
	echo ""
fi


echo "#################################################"
echo "#           SECTION: Interesting Files          #"
echo "#################################################"
echo ""

echo "----------------------------"
echo -e "${C_WHITE}SUID BINARIES${C_RESET}"
echo "----------------------------"
echo ""
defaultSetUIDs="/usr/bin/at /usr/bin/Xorg /usr/bin/crontab /usr/bin/chfn /usr/bin/sudo /usr/bin/gpasswd"
defaultSetUIDs="${defaultSetUIDs} /usr/bin/passwd /usr/bin/pkexec /bin/ping /bin/su /bin/umount"
defaultSetUIDs="${defaultSetUIDs} /bin/fusermount /bin/ping6 /bin/mount /sbin/mount /usr/bin/newgrp"
defaultSetUIDs="${defaultSetUIDs} /usr/lib/xorg/Xorg.wrap /usr/bin/traceroute6.iputils /usr/sbin/pppd"
defaultSetUIDs="${defaultSetUIDs} /usr/bin/arping /usr/bin/chsh /usr/bin/ntfs-3g /usr/sbin/exim4 /usr/bin/umount"
defaultSetUIDs="${defaultSetUIDs} /usr/lib/openssh/ssh-keysign /usr/bin/fusermount /usr/sbin/exim4 /usr/sbin/mount.cifs"
defaultSetUIDs="${defaultSetUIDs} /usr/bin/mount /usr/lib/dbus-1.0/dbus-daemon-launch-helper /usr/bin/bwrap /usr/lib/eject/dmcrypt-get-device"
print_notif "This could take a few moments . . ."
suids=$(find / -type f -perm -4000 -not -path "/snap/*" -not -path "/sys/*" -not -path "/run/*" -not -path "/proc/*" -not -path "/dev/*" -exec ls -la {} \; 2>/dev/null | grep -v /snap)
suidsFilenames=$(echo "$suids" | rev | cut -d " " -f 1 | rev)
while read -r suid; do
    if [ $(echo "$defaultSetUIDs" | grep -c "$suid") -eq 0 ]; then
        suid=$(echo "$suid" | sed "s/\//\\\\\//g")
        suids=$(echo "$suids" | sed "s/${suid}/${C_YELLOW_SED}${suid}${C_RESET_SED}/g")
    fi
done <<< "$suidsFilenames"
echo -e "$suids"
note_highlight "\"non-standard\" SUID binaries"

echo "----------------------------"
echo -e "${C_WHITE}NOTABLE SYSTEM FILES${C_RESET}"
echo "----------------------------"
echo ""
echo -e "${C_WHITE}Potential Config Files in /etc${C_RESET}"
out=$(find /etc -type f -not -path "/etc/speech-dispatcher/*" -not -path "/etc/fonts/*" -not -path "/etc/sane.d/*" -not -path "/etc/dbus-1/*" \( -name "*.cfg" -o -name "*.conf" -o -name "*.cnf" -o -name "*config" \) -exec ls -lh {} \; 2>/dev/null)
fnames=$(echo "$out" | rev | cut -d " " -f 1 | rev)
while read -r file; do

	if [ -w "$file" ]; then
        file=$(echo "$file" | sed "s/\//\\\\\//g")
		out=$(echo "$out" | sed -e "s/${file}/${C_YELLOW_SED}${file}${C_RESET_SED}/g")
	fi
done <<< "$fnames"
echo -e "$out"
note_highlight "config file is writable by current user"

echo -e "${C_WHITE}/var/log CURRENT Log Files (backups omitted)${C_RESET}"
out=$(find /var/log -not -path "/var/log/journal/*" -type f -exec ls -lh {} \; 2>/dev/null)
out=$( echo "$out" | egrep -v "(gz$|bz2$|xz$|\.\w{1,2}$)" )
fnames=$(echo "$out" | rev | cut -d " " -f 1 | rev)

while read -r file; do
	
	if [ -r "$file" ]; then
        file=$(echo "$file" | sed "s/\//\\\\\//g")
		out=$(echo "$out" | sed "s/${file}/${C_YELLOW_SED}${file}${C_RESET_SED}/g")
	fi
done <<< "$fnames"
echo -e "$out"
note_highlight "log file is readable by current user"

echo -e "${C_WHITE}/var/www Web Files${C_RESET}"
out=$(find /var/www -type f -exec ls -lh {} \; 2>/dev/null)
fnames=$(echo "$out" | rev | cut -d " " -f 1 | rev)
while read -r file; do
	
	if [ -w "$file" ]; then
        file=$(echo "$file" | sed "s/\//\\\\\//g")
		out=$(echo "$out" | sed "s/${file}/${C_YELLOW_SED}${file}${C_RESET_SED}/g")
	fi
done <<< "$fnames"
if [ -z "$out" ]; then
	print_notif "No files located in the /var/www directory . . ."
else
	echo -e "$out"
	echo ""
	note_highlight "web file is writable but current user"
fi

echo "----------------------------"
echo -e "${C_WHITE}FILES WITH CAPABILITIES${C_RESET}"
echo "----------------------------"
echo ""
out=$(getcap -r / 2>/dev/null)
if [ -z "$out" ]; then
	print_notif "No capabilities set on any files . . ."
else
	echo "$out"
	echo ""
fi
	

echo "----------------------------"
echo -e "${C_WHITE}USER PRESENCE FILES${C_RESET}"
echo "----------------------------"
echo ""
echo -e "${C_WHITE}Bash History Files${C_RESET}"
out=$(find / -type f -not -path "/proc/*" -not -path "/run/*" -not -path "/dev/*" -not -path "/sys/*" -name ".bash_history" -exec ls -lh {} \; 2>/dev/null)
if [ -z "$out" ]; then
	print_notif "No bash history files could be located . . ."
else
	fnames=$(echo "$out" | rev | cut -d " " -f 1 | rev)
	while read -r file; do
	
		if [ -r "$file" ]; then
			fileraw=$file
       	    file=$(echo "$file" | sed "s/\//\\\\\//g")
			out=$(echo "$out" | sed "s/${file}/${C_YELLOW_SED}${file}${C_RESET_SED}/g")
			out="$out\n$(print_notif 'Last 20 Commands...')\n"
			out="${out}$(tail -n 20 ${fileraw})"
		fi
	
	done <<< "$fnames"
	echo -e "$out"
	echo ""
fi

echo -e "${C_WHITE}MYSQL History Files${C_RESET}"
out=$(find / -type f -not -path "/proc/*" -not -path "/run/*" -not -path "/dev/*" -not -path "/sys/*" -name ".mysql_history" -exec ls -lh {} \; 2>/dev/null)
if [ -z "$out" ]; then
	print_notif "No mysql history files could be located . . ."
else
	fnames=$(echo "$out" | rev | cut -d " " -f 1 | rev)
	while read -r file; do
	
 	    if [ -r "$file" ]; then
			fileraw=$file
       	    file=$(echo "$file" | sed "s/\//\\\\\//g")
			out=$(echo "$out" | sed "s/${file}/${C_YELLOW_SED}${file}${C_RESET_SED}/g")
			out="$out\n$(print_notif 'Last 20 Commands...')\n"
			out="${out}$(tail -n 20 ${fileraw})"
		fi
	
	done <<< "$fnames"
	echo -e "$out"
	echo ""
fi

echo -e "${C_WHITE}viminfo Files${C_RESET}"
out=$(find / -type f -not -path "/proc/*" -not -path "/run/*" -not -path "/dev/*" -not -path "/sys/*" -name ".viminfo" -exec ls -lh {} \; 2>/dev/null)
if [ -z "$out" ]; then
	print_notif "No viminfo files could be located . . ."
else
	fnames=$(echo "$out" | rev | cut -d " " -f 1 | rev)
	while read -r file; do	
		if [ -r "$file" ]; then
       	    file=$(echo "$file" | sed "s/\//\\\\\//g")
			out=$(echo "$out" | sed "s/${file}/${C_YELLOW_SED}${file}${C_RESET_SED}/g")
		fi
	
	done <<< "$fnames"
	echo -e "$out"
	echo ""
fi

echo -e "${C_WHITE}Additional User Files${C_RESET}"
out=$(find / -type f -not -path "/proc/*" -not -path "/run/*" -not -path "/dev/*" -not -path "/sys/*" \( -name ".python_history" -o -name ".wget-hsts" -o -name ".sh_history" \) -exec ls -lh {} \; 2>/dev/null)
if [ -z "$out" ]; then
	print_notif "No additional history files could be located . . ."
else
	fnames=$(echo "$out" | rev | cut -d " " -f 1 | rev)
	while read -r file; do	
		if [ -r "$file" ]; then
       	    file=$(echo "$file" | sed "s/\//\\\\\//g")
			out=$(echo "$out" | sed "s/${file}/${C_YELLOW_SED}${file}${C_RESET_SED}/g")
		fi
	
	done <<< "$fnames"
	echo -e "$out"
	note_highlight "file is readable"
fi


echo "#################################################"
echo "#           SECTION: Processes and Jobs          #"
echo "#################################################"
echo ""

echo "----------------------------"
echo -e "${C_WHITE}RUNNING PROCESSES${C_RESET}"
echo "----------------------------"
echo ""
ps -elf | egrep -v "*]$"
echo ""

echo "----------------------------"
echo -e "${C_WHITE}CRON DIRECTORIES${C_RESET}"
echo "----------------------------"
echo ""
echo -e "${C_WHITE}/etc/cron.d${C_RESET}"
out=$(ls -lh /etc/cron.d | egrep -v "^total")
if [ -z "$out" ]; then
	print_notif "No jobs configured in cron.d . . ."
else
	echo "$out"
	echo ""
fi
echo -e "${C_WHITE}/etc/cron.hourly${C_RESET}"
out=$(ls -lh /etc/cron.hourly | egrep -v "^total")
if [ -z "$out" ]; then
	print_notif "No jobs configured in cron.hourly . . ."
else
	echo "$out"
	echo ""
fi
echo -e "${C_WHITE}/etc/cron.daily${C_RESET}"
out=$(ls -lh /etc/cron.daily | egrep -v "^total")
if [ -z "$out" ]; then
	print_notif "No jobs configured in cron.daily . . ."
else
	echo "$out"
	echo ""
fi
echo -e "${C_WHITE}/etc/cron.monthly${C_RESET}"
out=$(ls -lh /etc/cron.monthly | egrep -v "^total")
if [ -z "$out" ]; then
	print_notif "No jobs configured in cron.monthly . . ."
else
	echo "$out"
	echo ""
fi

echo -e "${C_WHITE}System Crontab Content${C_RESET}"
if [ -r "/etc/crontab" ]; then
	cat /etc/crontab | egrep -v "^#"
	echo ""
else
	print_notif "/etc/crontab is not readable by the current user . . ."
fi

echo -e "${C_WHITE}User Crontabs${C_RESET}"
out=$(ls -lh /var/spool/cron/crontabs 2>/dev/null | egrep -v "^total")
if [ -z "$out" ]; then
	print_notif "No User crontabs could be found . . ."
else
	echo "$out"
	echo ""
fi


echo "----------------------------"
echo -e "${C_WHITE}SYSTEMD RUNNING SERVICES${C_RESET}"
echo "----------------------------"
echo ""
if [ -z "$(which systemctl 2>/dev/null)" ]; then
	print_notif "Systemd doesn't appear to be installed . . ."
else
	systemctl list-units --type service | grep "running"
	echo ""
fi

echo "----------------------------"
echo -e "${C_WHITE}'LIVING OFF THE LAND' UTILITIES${C_RESET}"
echo "----------------------------"
echo ""
which python python3 nc wget curl ssh perl git ftp tftp sftp php nmap apt-get yum smbclient socat telnet tcpdump 2>/dev/null
echo ""
print_success "Script complete!"
