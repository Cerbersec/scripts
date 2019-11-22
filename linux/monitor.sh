#!/bin/bash

ifconfig wlp2s0 down
iwconfig wlp2s0 mode monitor
macchanger -r wlp2s0
ifconfig wlp2s0 up
iwconfig wlp2s0 | grep Mode