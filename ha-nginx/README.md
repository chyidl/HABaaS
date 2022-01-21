# Setup Highly Available Nginx with KeepAlived

* Lab Details

|IP | 主机| 组件| 软件| 备注|
|:--|:----|:----|:----|:----|
| 172.16.30.175| Node 1| Keepalived| Nginx| Linux centos 3.10.0-957.el7.x86_64 #1 SMP Thu Nov 8 23:39:32 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux|
| 172.16.30.174| Node 2| Keepalived| Nginx| Linux centos 3.10.0-957.el7.x86_64 #1 SMP Thu Nov 8 23:39:32 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux|
| 172.16.30.205| Virtual IP| | | |

* Step 1) - Install Nginx Web Server
```
(centos 7)
$ sudo yum install epel-release -y
$ sudo yum install nginx
```

* Step 2) - Configure Custom index.html file for both nodes
```
# node 1
$ echo "<h1>This is NGINX Web Server from Node 1</h1>" | sudo tee /usr/share/nginx/html/index.html
# node 2
$ echo "<h1>This is NGINX Web Server from Node 2</h1>" | sudo tee /usr/share/nginx/html/index.html
```

* Step 3) - Allow Nginx port in firewall and start its service
```
$ sudo firewall-cmd --permanent --add-service=http
$ sudo firewall-cmd -reload
```

* Step 4) - Start and enable nginx
```
$ sudo systemctl start nginx
$ sudo systemctl enable nginx
# running test
 [blocface@centos ~]$ curl http://172.16.30.175
<h1>This is NGINX Web Server from Node 1</h1>
 [blocface@centos ~]$ curl http://172.16.30.174
<h1>This is NGINX Web Server from Node 2</h1>
```

* Step 5) - Install and Configure Keepalived
```
$ sudo yum install -y keepalived
# Take backup of configuration file
$ sudo cp /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf-bak
# Replace the content of keepalived.conf/check-nginx.sh with below
```
- [keepalived.conf](./keepalived.conf)
- [check-nginx](./check-nginx.sh)

* Step 6) - Copy keepalived.conf / check-nginx.sh from node1 to node2
```
$ scp /etc/keepalived/keepalived.conf blocface@172.16.30.174:/etc/keepalived
$ scp /bin/check_nginx.sh blocface@172.16.30.174:/bin

1. Changes State from MASTER to BACKUP
2. Lower the priority by setting it as 100
```

* Step 7) - Start keepalived service running beneath systemctl commands from both nodes
```
$ sudo systemctl start keepalived
$ sudo systemctl enable keepalived
[blocface@centos ~]$ sudo systemctl status keepalived
● keepalived.service - LVS and VRRP High Availability Monitor
   Loaded: loaded (/usr/lib/systemd/system/keepalived.service; enabled; vendor preset: disabled)
   Active: active (running) since 五 2022-01-21 15:36:20 CST; 8min ago
  Process: 3896 ExecStart=/usr/sbin/keepalived $KEEPALIVED_OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 3898 (keepalived)
    Tasks: 3
   Memory: 1.7M
   CGroup: /system.slice/keepalived.service
           ├─3898 /usr/sbin/keepalived -D
           ├─3899 /usr/sbin/keepalived -D
           └─3900 /usr/sbin/keepalived -D

1月 21 15:36:24 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205
1月 21 15:36:24 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205
1月 21 15:36:24 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205
1月 21 15:36:24 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205
1月 21 15:36:29 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205
1月 21 15:36:29 centos Keepalived_vrrp[3900]: VRRP_Instance(VI_1) Sending/queueing gratuitous ARPs on eth0 for 172.16.30.205
1月 21 15:36:29 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205
1月 21 15:36:29 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205
1月 21 15:36:29 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205
1月 21 15:36:29 centos Keepalived_vrrp[3900]: Sending gratuitous ARP on eth0 for 172.16.30.205

[blocface@centos ~]$ ip add show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:7d:64:c4 brd ff:ff:ff:ff:ff:ff
    inet 172.16.30.175/24 brd 172.16.30.255 scope global noprefixroute dynamic eth0
       valid_lft 56665sec preferred_lft 56665sec
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
