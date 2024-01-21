# RED ISP
# chipi chipi chapa chapa

**Basic requirements ( 50% score if passes the tests )**
1. ~~Your ISP network has at least 3 IPv4 segments - “private”, “users”, and “company”.~~

2. ~~“Users” segment shall have NAT.~~

3. Your ISP shall have at least 3 plans - with limited speed, with limited traffic, with unlimited speed and traffic

4. You should collect traffic statistics to fulfill plans requirements

5. ~~You should export your networks to BGP using the ASN and IP assigned~~

6. ~~You should import other networks from BGP using the peer ASN and the peer IP~~

7. Your system shall pass the implementation tests

**Bonus points to max the score**
- OSPF routing between segments ( + 10% )
- At least one segment is connected via VPN ( +10 %)
- DNS service for ISP clients ( + 10% )
- DHCP server in “users” segment ( + 10% )
- DMZ segment with ISP services ( HTTP, FTP, SMTP, at least one ) ( + 10% )
- Billing website with traffic statistics and plan info for my IP ( +10% )
- Full IPv6 support, including BGP IPv6 routes exchange ( +20% )

## chapa chapa chipi chipi 

We need 2 virtual machines and 1 host. One vm will be company, the other will be user. On the host will work BGP. VMs are taken from DB course)

### VBox preferences
We need to add a host-only network to the virtual machine. To do so, go to `File > Preferences > Network > Host-only Networks` and add a new one. Then, go to the virtual machine settings and add a new network adapter with the new host-only network. Finally, start the virtual machine and run `ip a` to check the new network adapter.

Additionaly, we need Internal Network for communication between the virtual machines. Set up the 'bibka' network name for both machines.

### For users
Vbox will automatically set up needed network interfaces. We need to set up static IP addresses for them. To do so, run [user.sh](users/users.sh) script. It will set up static IP addresses for the interfaces and will add routing to the host-only network. For future test we can add user by running [create_interfaces.sh](users/create_interfaces.sh) script. 

NAT made by iptables. To set up all needed in [user.sh](users/users.sh) script.

For traffic control we use tc. To set up we can use command `sudo tc qdisc add dev enp0s3 root tbf rate 1mbit burst 32kbit latency 400ms`. To check the result we can use `tc -s qdisc ls dev enp0s3` command. To delete all rules we can use `sudo tc qdisc del dev enp0s3 root`.

For speedtest just use nc and dd. For example, `dd if=/dev/zero bs=1M count=100 | nc bla-bla-bla 1234` and `nc -l -vv 1234 `.

If everything is ok, we can see next `ip a` output:
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:f3:8a:e7 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.2/12 brd 172.31.255.255 scope global dynamic noprefixroute enp0s3
       valid_lft 381sec preferred_lft 381sec
    inet 10.204.0.2/17 scope global enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.56.2/32 scope global enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::cdc0:3007:feab:10ce/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:e7:9f:74 brd ff:ff:ff:ff:ff:ff
    inet 172.16.0.1/12 scope global enp0s8
       valid_lft forever preferred_lft forever
4: user: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether c8:d7:4a:4e:47:50 brd ff:ff:ff:ff:ff:ff
    inet 172.18.100.100/32 scope global user
       valid_lft forever preferred_lft forever
    inet6 fe80::cad7:4aff:fe4e:4750/64 scope link 
       valid_lft forever preferred_lft forever
```

### For company
Oh, it's the same as for users, but we don't need NAT. So, we can use [create_interfaces.sh](company/create_interfaces.sh) script to set up static IP addresses for the interfaces and will add routing to the host-only network. And [companies.sh](company/companies.sh) script to set up traffic forwarding.

### For host
We need to set up something like this:
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: wlp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 48:bf:6b:f2:64:70 brd ff:ff:ff:ff:ff:ff
    inet 172.29.66.208/22 brd 172.29.67.255 scope global dynamic noprefixroute wlp3s0
       valid_lft 2117sec preferred_lft 2117sec
    inet6 fe80::67e6:307f:67b6:7c7f/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: vboxnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 0a:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.1/24 brd 192.168.56.255 scope global vboxnet0
       valid_lft forever preferred_lft forever
    inet 10.204.0.1/17 scope global vboxnet0
       valid_lft forever preferred_lft forever
    inet6 fe80::800:27ff:fe00:0/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
```

And just run [bgp.sh](bgp/bgp.sh) script. It will set up bgp and will add routing to the host-only network. If there is no needed interface, we can add it by running [create_interfaces.sh](bgp/create_interfaces.sh) script.