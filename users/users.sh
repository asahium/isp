#!/bin/bash

# init ifaces
ip a add 10.204.0.2/17 dev enp0s3
ip a del 172.29.66.143/22 dev enp0s3
ip a add 172.16.0.1/12 dev enp0s8

# launch dhcp server 
pkill dnsmasq
dnsmasq --interface=enp0s8 --bind-interfaces --dhcp-range=172.16.0.2,172.31.255.254

sysctl -w net.ipv4.ip_forward=1

iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s8 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

ip ro add 10.204.128.0/17 via 10.204.0.3
ip ro add default via 10.204.0.1