# before removing internet connection
# apt update
# apt install bird

# init ifaces

ip a add 10.204.0.1/17 dev vboxnet0
ip a add 10.10.10.204/24 dev wlp3s0

# enable ipv4 forwarding
sysctl -w net.ipv4.ip_forward=1

# clear iptables
iptables -F
# enable nats
sudo iptables -A FORWARD -i wlp3s0 -o vboxnet0 -j ACCEPT
sudo iptables -A FORWARD -i vboxnet0 -o wlp3s0 -j ACCEPT

# init bgp
rm /etc/bird.conf

cat > /etc/bird.conf << EOF
router id 10.10.10.204;

protocol kernel {
 ipv4 {
 table master4;
 import all;
 export all;   # Actually insert routes into the kernel routing table
 };
 scan time 60;
 learn;
}

protocol device {
 scan time 60;
}

protocol static static_bgp {
 ipv4 {
  import all;
  };
 route 10.204.128.0/17 via 10.204.0.3;
 route 10.204.0.2/32 via 10.204.0.1;
#    route fc00::2004::::::::::::2/128 via fc00::2004::::::::::::1;
#    route fc00::2004:: :: :: :: :: ::0/128 via fc00::2004::::::::::::3;
}

protocol bgp peer_2 {
 ipv4 {
  import all;
  export where proto = "static_bgp";
};
 local as 65204;
 neighbor 10.10.10.203 as 65203;
}
EOF

pkill bird
bird -c /etc/bird.conf
