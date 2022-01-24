# HAProxy
> HAProxy, which stands for High Availability Proxy, is a popular open source software TCP/HTTP Load Balancer and proxying solution which can be run on Linux.


## HAProxy Terminology

* Access Control List (ACL)
> allows flexible network traffic forwarding based on a variety of factors like pattern-matching and the number of connections to a backend

* Backend
> A backend is a set of servers that receives forwarded requests.
```
# balance roundrobin
# mode http
```

* Frontend
> A frontend defines how requests should be forwarded to backends.

## Types of Load Balancing

* No Load balancing
![no load balancing](./images/no_load_balance.png)

* Layer 4 Load Balancing
> layer 4 (transport layer) load balancing
> Load balancing this way will forward user traffic based on IP range and port
![layer 4 Load Balancing](./images/layer_4_load_balancing.png)

* Layer 7 Load Balancing
> Layer 7 allows the load balancer to forward requests to different backend servers based on the content of the user's request
![layer 7 load balance](./images/layer_7_load_balancing.png)


## Load Balancing Algorithms

* roundrobin
> Round Robin select servers in turns. This is the default algorithm

* leastconn
> Selects the server with the least number of connections-it is recommended for longer sessions.
> Servers in the same backend are also rotated in a round-robin fashion

* source
> This select which server to use based on a hash of the source IP. This is one method to ensure that a user will connect to the same server.
