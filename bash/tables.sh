#!/bin/bash -x

# **DEFINE CUSTOM RULES NEAR END OF SCRIPT**

# Set variables
IPT=$(which iptables)

TCPLIST=/tmp/TCPLIST
UDPLIST=/tmp/UDPLIST

# Listening ports
ss -lnt | awk '{print $4;}' | rev | cut -f 1 -d : | rev | sort | uniq | head -n -1 > $TCPLIST
ss -lnu | awk '{print $4;}' | rev | cut -f 1 -d : | rev | sort | uniq | head -n -1 > $UDPLIST

# Open ports
function tcplist {
    if [ $# -ne 0 ]; then
        for i in $@; do
            $IPT -A INPUT -p tcp --dport $i -j ACCEPT
        done
    fi
}

function udplist {
    if [ $# -ne 0 ]; then
        for i in $@; do
            $IPT -A INPUT -p udp --dport $i -j ACCEPT
        done
    fi
}

# Initial paramiters
$IPT -F
$IPT -t nat -F

$IPT -N EXPLICIT

$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT

$IPT -I INPUT -j EXPLICIT

# Primary paramiters **SEE CUSTOM RULES NEAR END OF SCRIPT**

# Secondary parameters
tcplist $(cat $TCPLIST) #<-- Port numbers may be manually appended here
udplist $(cat $UDPLIST) #<-- Port numbers may be manually appended here

# Closing parameters
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Router settings
#$IPT -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#$IPT -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
#$IPT -A FORWARD -i eth1 -o eth0 -j ACCEPT

# Primary paramiters **DEFINE CUSTOM RULES HERE**
#$IPT -A EXPLICIT -p tcp --syn --dport 22 -m connlimit --connlimit-above 2 -j REJECT

# Save configuration
#service iptables save
