#!/bin/bash

trap ctrl_c INT
function ctrl_c() {

    echo "[!] Fixing routes..."
    route del default gw ${SINKHOLE}
    route add default gw ${oldDefault} enp0s3
}


if [ $(id -u) -ne 0 ]; then
    echo "[-] Please run as root!"
    exit 1
fi

SINKHOLE="192.168.2.2"
echo "1" > /proc/sys/net/ipv4/ip_forward
oldDefault=$(route -n | grep UG | sed -e 's/  */ /g' | cut -d " " -f 2)
route del default gw ${oldDefault}
route add default gw ${SINKHOLE} enp0s3
echo "Routing has been changed to direct all traffic to ${SINKHOLE}. Press enter to re-adjust routes when done . . ."
read null
route del default gw ${SINKHOLE}
route add default gw ${oldDefault} enp0s3
exit 0