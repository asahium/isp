sudo modprobe dummy
sudo ip link add eth0 type dummy
ip link show eth0
sudo ifconfig eth0 hw ether C8:D7:4A:4E:47:50
sudo ip addr add 192.168.1.100/24 brd + dev eth0 label eth0:0
sudo ip link set dev eth0 up

echo "iface 1 done"

sudo modprobe dummy
sudo ip link add eth1 type dummy
ip link show eth1
sudo ifconfig eth1 hw ether C8:D7:4A:4E:47:52
sudo ip addr add 192.168.1.100/24 brd + dev eth1 label eth1:0
sudo ip link set dev eth1 up

echo "iface 2 done"

ip a 