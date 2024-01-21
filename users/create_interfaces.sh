sudo modprobe dummy
sudo ip link add user type dummy
ip link show user
sudo ifconfig user hw ether C8:D7:4A:4E:47:50
sudo ip a add 172.18.100.100 dev user
sudo ip link set dev user up

echo "iface user done"

ip a 