# ifconfig vs ip

* ifconfig (command from net-tools package)
```
  1. Displaying or Modifying Interface properties.
  2. Adding, Removing ARP Cache entries along creating new Static ARP entry for a host.
  3. Displaying MAC addresses associated with all the interfaces.
  4. Displaying and modifying kernel routing tables.
```

* ip (command from iproute2util package)
```
It is functionaly organized on two layers of Networking Stack i.e.
  Layer 2 (Link Layer)
  Layer 3 (IP Layer)
```


## 1. Displaying all Network Interfaces in Linux
* **ifconfig** only shows enabled interfaces, **ip** shows all the interfaces whether enabled or disabled.

  - **ifconfig**
```
[blocface@centos ~]$ ifconfig
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:69:2b:1b:fb  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.16.30.175  netmask 255.255.255.0  broadcast 172.16.30.255
        inet6 fe80::336b:6677:b1d8:120d  prefixlen 64  scopeid 0x20<link>
        inet6 fe80::996c:f061:b22c:e8c7  prefixlen 64  scopeid 0x20<link>
        inet6 fe80::754d:e709:668a:62fe  prefixlen 64  scopeid 0x20<link>
        ether 52:54:00:7d:64:c4  txqueuelen 1000  (Ethernet)
        RX packets 1656346  bytes 554537586 (528.8 MiB)
        RX errors 0  dropped 7  overruns 0  frame 0
        TX packets 1363572  bytes 77957659 (74.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 48  bytes 4158 (4.0 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 48  bytes 4158 (4.0 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
  - **ip a**
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:7d:64:c4 brd ff:ff:ff:ff:ff:ff
    inet 172.16.30.175/24 brd 172.16.30.255 scope global noprefixroute dynamic eth0
       valid_lft 53562sec preferred_lft 53562sec
    inet 172.16.30.205/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::996c:f061:b22c:e8c7/64 scope link tentative noprefixroute dadfailed
       valid_lft forever preferred_lft forever
    inet6 fe80::336b:6677:b1d8:120d/64 scope link tentative noprefixroute dadfailed
       valid_lft forever preferred_lft forever
    inet6 fe80::754d:e709:668a:62fe/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:69:2b:1b:fb brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
```

## 2. Adding or Deleting an IP Address in Linux
  - **ifconfig** - Add/Del IP Address
  ```
  # ifconfig eth0 add/del 192.168.80.174
  ```

  - **ip** - Add/Del IP Address
  ```
  # ip a add 192.168.80.174 dev eth0
  ```


## 参考资料

[ifconfig vs ip command compare network configuration](https://www.tecmint.com/ifconfig-vs-ip-command-comparing-network-configuration/)

