# MySQL Group Replication

* **Group Replication**
  > Group replication is a way of implementing a more flexible, fault-tolerant replication mechanism. This process involves establishing a pool of servers that are each involved in ensuring data is copied correctly.
  > Membership negotiation, failure detection, and message delivery is provided through an implementation of the Paxos concensus algorithm.


## Install the Latest MySQL on Centos 7
```
# curl
#   -O instructs curl to output to a file instead of standed output
#   -L flag makes curl follow HTTP redirects
$ curl -OL https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rp://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm

# Need to prepare the repository
$ sudo rpm -i mysql80-community-release-el7-5.rpm

# Install MySQL
$ sudo yum install mysql-server

# Start MySQL
$ sudo systemctl start mysqld

# Check If it is working properly
$ sudo systemctl status mysqld

# Changing MySQL Root User Password
$ sudo grep 'password' /var/log/mysqld.log
  # In order to change it
  $ sudo mysql_secure_installation

# Checking Current MySQL Version
$ mysql -u root -p

# Resetting the MySQL Root Password
  # Stop the MySQL server
  $ sudo systemctl stop mysqld

  # Restart MySQL in safe mode
  $ sudo mysqld_safe --skip-grant-tables

  # reconnect to MySQL
  $ mysql -uroot
  > USE MYSQL;
  > UPDATE USER SET PASSWORD=PASSWORD("newpassword") WHERE USER='root';
  > FLUSH PRIVILEGES;
  > EXIT;

  # restart MySQL
  $ sudo systemctl start mysqld

# Creating a New MySQL User, Database
  # Create a new dataabse
  > CREATE DATABASE newdb;

  # Create a new user
  > CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';

  # Delete a user
  > DROP USER 'username'@'localhost';

# Managing MySQL User Permissions
  # Grant access
  #   - SELECT: read
  #   - CREATE: create
  #   - DROP: remove tables
  #   - DELETE: delete rows from tables
  #   - INSERT: add in rows into tables
  #   - UPDATE: update the rows
  #   - GRANT OPTION: they can grant or removes the privileges of other users.
  > GRANT ALL PRIVILEGES ON newdb.* TO 'username'@'localhost';

  # remove access
  > REVOKE permission_type on newdb.* TO 'username'@'localhost';

  # check current privileges a user
  > SHOW GRANTS username;

  # reset all the privileges(all changes to take effect)
  > FLUSH PRIVILEGES;
```
