---
slug: "mariadb-notes"
title: "MariaDB Cheat Sheet: Setup, Commands & Export"
description: "Master MariaDB with this complete cheat sheet and technical guide. Learn database installation, user management, security, and essential CLI commands."
tags: ["database", "mariadb"]
keywords: "MariaDB cheat sheet, MariaDB setup guide, database management, MariaDB CLI commands, secure MariaDB installation, create MariaDB user, export MariaDB database"
date: 2025-09-08
---

## Setup

1. Install MariaDB and its client libraries:

```bash
pacman -S mariadb mariadb-clients mariadb-libs
```

2. Initialize MariaDB data directory:

```bash
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
```

This command serves multiple purpose:

- Generates tables that handle the store of user, privileges, time zones, etc.
- Setup the main user so MariaDB can read and write.
- Finally sets where the software lives and stored the data.

2. Start the MariaDB service:

```bash
sudo systemctl start mariadb
```

3. Secure Installation

Run the built-in script to set root password and secure MariaDB:

```bash
sudo mysql_secure_installation
```

This will allow you to:

- Set the root password
- Remove anonymous users
- Disallow root login remotely
- Remove test database

## Enter the MariaDB Command Line

Switch to the MariaDB command line with:

```bash
sudo mariadb
```

To exit the MariaDB CLI:

```sql
exit;
```

## Basics of MariaDB

Creating a New User

> [!WARNING]
> Use a dedicated user per database for security.

```sql
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypassword';
```

Creating a Database

```sql
CREATE DATABASE mydb;
```

Grant privileges on the database to your user:

```sql
GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'localhost';
FLUSH PRIVILEGES;
```

To revoke privileges:

```sql
REVOKE ALL PRIVILEGES ON mydb.* FROM 'myuser'@'localhost';
FLUSH PRIVILEGES;
```

To delete a database:

```sql
DROP DATABASE mydb;
```

To delete a user:

```sql
DROP USER 'myuser'@'localhost';
```

## Useful Commands

Show users:

```sql
SELECT User, Host FROM mysql.user;
```

Show databases:

```sql
SHOW DATABASES;
```

Connect to a specific database:

```sql
USE mydb;
```

Show tables in the current database:

```sql
SHOW TABLES;
```

Describe table structure:

```sql
DESCRIBE table_name;
```

## Export DB into a file

```bash
mariadb-dump -u myuser -p --no-data mydb > mydb.sql
```

Change `myuser` and `mydb` accordingly to your MariaDB user and database, you can also specify the place where the file will be saved `mydb.sql`
