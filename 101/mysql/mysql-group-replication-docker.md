# Setting up MySQL Group Replication with MySQL Docker images
> **MySQL Group Replication (GR)** is a MySQL Server plugin that enables you to create elastic, highly-available, fault-tolerant replication topologies.

* single-primary mode:
> with automatic primary election, where only one server accepts updates at a time.
> designates the first group member as the single primary server which will handle all write operations.

* multi-primary mode:
> where all servers can accept updates, even if they are issued concurrently.
> A multi-primary mode a allows writes to any of the group members


## Docker
> an open source framework that automates deployment and provisioning, and simplifies distribution of applications in lightweight and portable containers.

## Overview
* download the MySQL 8 image from Docker Hub
```
$ docker pull mysql/mysql-server:8.0
$ docker images
```
* create a Docker network named groupnet
```
$ docker network create groupnet
$ docker network ls
```
* setup a Multi Primary GR topology with 3 group members in different containers
```
# single-primary mode
for N in 1 2 3
do docker run --name=node$N --net=groupnet --hostname=node$N \
  -v $PWD/d$N:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypass \
  -d mysql/mysql-server:8.0.28 \
  --server-id=$N \
  --log-bin='mysql-bin-1.log' \
  --enforce-gtid-consistency='ON' \
  --log-slave-updates='ON' \
  --gtid-mode='ON' \
  --transaction-write-set-extraction='XXHASH64' \
  --binlog-checksum='NONE' \
  --master-info-repository='TABLE' \
  --relay-log-info-repository='TABLE' \
  --plugin-load='group_replication.so' \
  --relay-log-recovery='ON' \
  --loose-group-replication-start-on-boot='OFF' \
  --loose-group-replication-group-name='aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' \
  --loose-group-replication-local-address="node$N:33061" \
  --loose-group-replication-group-seeds='node1:33061,node2:33061,node3:33061' \
  --loose-group-replication-single-primary-mode='ON' \
  --loose-group-replication-enforce-update-everywhere-checks='OFF'
done

# multi-primary mode
for N in 1 2 3
do docker run -d --name=node$N --net=groupnet --hostname=node$N \
  -v $PWD/d$N:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mypass \
  mysql/mysql-server:8.0.28 \
  --server-id=$N \
  --log-bin='mysql-bin-1.log' \
  --enforce-gtid-consistency='ON' \
  --log-slave-updates='ON' \
  --gtid-mode='ON' \
  --transaction-write-set-extraction='XXHASH64' \
  --binlog-checksum='NONE' \
  --master-info-repository='TABLE' \
  --relay-log-info-repository='TABLE' \
  --plugin-load='group_replication.so' \
  --relay-log-recovery='ON' \
  --loose-group-replication-start-on-boot='OFF' \
  --loose-group-replication-group-name='aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' \
  --loose-group-replication-local-address="node$N:33061" \
  --loose-group-replication-group-seeds='node1:33061,node2:33061,node3:33061' \
  --loose-group-replication-single-primary-mode='OFF' \
  --loose-group-replication-enforce-update-everywhere-checks='ON'
done

# whether the container started
chyiyaqing in chyi/devops/mysql at chyiyaqing-PowerEdge-R720
➜ docker ps | grep mysql
39cb705f92bd   mysql/mysql-server:8.0.28                                       "/entrypoint.sh --se…"   About a minute ago   Up 59 seconds (healthy)       3306/tcp, 33060-33061/tcp   node3
a13829351751   mysql/mysql-server:8.0.28                                       "/entrypoint.sh --se…"   About a minute ago   Up About a minute (healthy)   3306/tcp, 33060-33061/tcp   node2
13252285f9d4   mysql/mysql-server:8.0.28                                       "/entrypoint.sh --se…"   About a minute ago   Up About a minute (healthy)   3306/tcp, 33060-33061/tcp   node1
```

## Setting up and starting GR in the containers
> Run MySQL GR setup commands from outside the containers using the flag "-it"
```
# execute these commands on node1 which will boostrap the group
chyiyaqing in chyi/devops/mysql at chyiyaqing-PowerEdge-R720
➜ docker exec -it node1 mysql -uroot -pmypass \
  -e "SET @@GLOBAL.group_replication_bootstrap_group=1;" \
  -e "create user 'repl'@'%';" \
  -e "GRANT REPLICATION SLAVE ON *.* TO repl@'%';" \
  -e "flush privileges;" \
  -e "change master to master_user='repl' for channel 'group_replication_recovery';" \
  -e "START GROUP_REPLICATION;" \
  -e "SET @@GLOBAL.group_replication_bootstrap_group=0;" \
  -e "SELECT * FROM performance_schema.replication_group_members;"
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 3c80cf32-7e78-11ec-adc3-0242ac120002 | node1       |        3306 | RECOVERING   | PRIMARY     | 8.0.28         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+

# node2 and node3 execute the below command
chyiyaqing in chyi/devops/mysql at chyiyaqing-PowerEdge-R720
➜ for N in 2 3
  do docker exec -it node$N mysql -uroot -pmypass \
    -e "change master to master_user='repl' for channel 'group_replication_recovery';" \
    -e "START GROUP_REPLICATION;"
done

mysql: [Warning] Using a password on the command line interface can be insecure.
mysql: [Warning] Using a password on the command line interface can be insecure.

# Use the performance schema tables to monitor GR
chyiyaqing in chyi/devops/mysql at chyiyaqing-PowerEdge-R720 took 4s
➜ docker exec -it node1 mysql -uroot -pmypass \
  -e "SELECT * FROM performance_schema.replication_group_members;"
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 3c80cf32-7e78-11ec-adc3-0242ac120002 | node1       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3cd152bc-7e78-11ec-ad99-0242ac120003 | node2       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3d40ebd6-7e78-11ec-aed9-0242ac120004 | node3       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
```

## Adding some data

```
# create database & table
chyiyaqing in ~ at chyiyaqing-PowerEdge-R720
➜ docker exec -it node1 mysql -uroot -pmypass -e "create database IF NOT EXISTS TEST; use TEST; CREATE TABLE t1 (id INT NOT NULL PRIMARY KEY) ENGINE=InnoDB; show tables;"
mysql: [Warning] Using a password on the command line interface can be insecure.
+----------------+
| Tables_in_TEST |
+----------------+
| t1             |
+----------------+

# add some data by connect to the other group members
chyiyaqing in chyi/devops/mysql at chyiyaqing-PowerEdge-R720
➜ for N in 2 3
do docker exec -it node$N mysql -uroot -pmypass \
  -e "INSERT INTO TEST.t1 VALUES($N);"
done
mysql: [Warning] Using a password on the command line interface can be insecure.
mysql: [Warning] Using a password on the command line interface can be insecure.

# check whether the data was inserted
chyiyaqing in chyi/devops/mysql at chyiyaqing-PowerEdge-R720
➜ for N in 1 2 3
do docker exec -it node$N mysql -uroot -pmypass \
  -e "SHOW VARIABLES WHERE Variable_name = 'hostname';" \
  -e "SELECT * FROM TEST.t1;"
done
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| hostname      | node1 |
+---------------+-------+
+----+
| id |
+----+
|  2 |
|  3 |
+----+
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| hostname      | node2 |
+---------------+-------+
+----+
| id |
+----+
|  2 |
|  3 |
+----+
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| hostname      | node3 |
+---------------+-------+
+----+
| id |
+----+
|  2 |
|  3 |
+----+
```

## GR fault tolerance scenarios (容错场景)
```
# set the option **group_replication_exit_state_action** to **READ_ONLY**, so node3 will not be killed when it goes to ERROR state.
chyiyaqing in chyi/devops/mysql at chyiyaqing-PowerEdge-R720
➜ docker exec -it node3 mysql -uroot -pmypass -e "set @@global.group_replication_exit_state_action=READ_ONLY;"
mysql: [Warning] Using a password on the command line interface can be insecure.


chyiyaqing in chyi/devops/mysql at chyiyaqing-PowerEdge-R720
➜ docker exec -it node3 mysql -uroot -pmypass -e "select @@global.group_replication_exit_state_action;"
mysql: [Warning] Using a password on the command line interface can be insecure.
+----------------------------------------------+
| @@global.group_replication_exit_state_action |
+----------------------------------------------+
| READ_ONLY                                    |
+----------------------------------------------+

# disconnect node3 from the groupnet network
$ docker network disconnect groupnet node3

# Checking the group members
chyiyaqing in ~ at chyiyaqing-PowerEdge-R720
➜ for N in 1 3
do docker exec -it node$N mysql -uroot -pmypass \
  -e "SHOW VARIABLES WHERE Variable_name = 'hostname';" \
  -e "SELECT * FROM performance_schema.replication_group_members;"
done
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| hostname      | node1 |
+---------------+-------+
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 3c80cf32-7e78-11ec-adc3-0242ac120002 | node1       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3cd152bc-7e78-11ec-ad99-0242ac120003 | node2       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| hostname      | node3 |
+---------------+-------+
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 3c80cf32-7e78-11ec-adc3-0242ac120002 | node1       |        3306 | UNREACHABLE  | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3cd152bc-7e78-11ec-ad99-0242ac120003 | node2       |        3306 | UNREACHABLE  | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3d40ebd6-7e78-11ec-aed9-0242ac120004 | node3       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+

# reestablish the network connection in node3 and rejoin the node
$ docker network connect groupnet node3

# Rejoining node3
$ docker exec -it node3 mysql -uroot -pmypass \
  -e "STOP GROUP_REPLICATION; START GROUP_REPLICATION;"

# Checking the group members
chyiyaqing in ~ at chyiyaqing-PowerEdge-R720
➜ for N in 1 3
do docker exec -it node$N mysql -uroot -pmypass \
  -e "SHOW VARIABLES WHERE Variable_name = 'hostname';" \
  -e "SELECT * FROM performance_schema.replication_group_members;"
done
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| hostname      | node1 |
+---------------+-------+
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 3c80cf32-7e78-11ec-adc3-0242ac120002 | node1       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3cd152bc-7e78-11ec-ad99-0242ac120003 | node2       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3d40ebd6-7e78-11ec-aed9-0242ac120004 | node3       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| hostname      | node3 |
+---------------+-------+
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 3c80cf32-7e78-11ec-adc3-0242ac120002 | node1       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3cd152bc-7e78-11ec-ad99-0242ac120003 | node2       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3d40ebd6-7e78-11ec-aed9-0242ac120004 | node3       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+

# stop or kill a node
chyiyaqing in ~ at chyiyaqing-PowerEdge-R720
➜ docker kill node3
node3

# check the group members again
chyiyaqing in ~ at chyiyaqing-PowerEdge-R720
➜ docker exec -it node1 mysql -uroot -pmypass \
  -e "SELECT * FROM performance_schema.replication_group_members;"
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 3c80cf32-7e78-11ec-adc3-0242ac120002 | node1       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3cd152bc-7e78-11ec-ad99-0242ac120003 | node2       |        3306 | ONLINE       | PRIMARY     | 8.0.28         | XCom                       |
| group_replication_applier | 3d40ebd6-7e78-11ec-aed9-0242ac120004 | node3       |        3306 | UNREACHABLE  | PRIMARY     | 8.0.28         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
```

## Cleaning up: stopping containers, removing created network and image
```

```

## Summary

