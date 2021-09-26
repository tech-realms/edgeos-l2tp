#!/bin/vbash

set -e
read -p "Set interface (ex: eth0): " IFACE
read -p "Set vpn username: " USER
read -p "Set vpn password: " PASS
read -p "Set IP range start: " SIP
read -p "Set IP range end: " EIP
# read -p "Set DNS range start: " SDNS
# read -p "Set ENS range end: " EDNS
read -p "Set pre-shared key: " PSK
PIP=$(curl -s https://ifconfig.me)

source /opt/vyatta/etc/functions/script-template

configure

set vpn ipsec ipsec-interfaces interface $IFACE

set vpn ipsec nat-traversal enable

set vpn l2tp remote-access authentication mode local

set vpn l2tp remote-access \
        authentication local-users \
        username $USER \
        password $PASS

set vpn l2tp remote-access client-ip-pool start $SIP

set vpn l2tp remote-access client-ip-pool stop $EIP

set vpn l2tp remote-access dns-servers server-1 8.8.8.8

set vpn l2tp remote-access dns-servers server-2 4.2.2.2

set vpn l2tp remote-access ipsec-settings authentication mode pre-shared-secret

set vpn l2tp remote-access ipsec-settings authentication pre-shared-secret $PSK

set vpn l2tp remote-access ipsec-settings ike-lifetime 3600

set vpn ipsec auto-firewall-nat-exclude enable

## DHCP
# set vpn l2tp remote-access dhcp-interface $IFACE

## STATIC
set vpn l2tp remote-access outside-address $PIP

commit && save

exit
