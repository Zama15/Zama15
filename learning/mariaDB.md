# MariaDB Setup Guide

## Setup

Install MariaDB and its client libraries:

```bash
pacman -S mariadb mariadb-clients mariadb-libs
```

Start the MariaDB service using **sysz** (recommended):

```bash
sysz
```

If you haven’t installed `sysz` yet:

```bash
pacman -S sysz
```

> ![NOTE]
> I deeply recommend this package to manage the system services, is very usuful, but it just a preference of mine, use at you own discretion.

## MariaDB Manage

> !\[NOTE]
> I recommend using the MariaDB command line for most database management tasks, similar to PostgreSQL.

### Before Starting Service

Run this line

```bash
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
```

### Secure Installation

Run the built-in script to set root password and secure MariaDB:

```bash
sudo mysql_secure_installation
```

This will allow you to:

- Set the root password
- Remove anonymous users
- Disallow root login remotely
- Remove test database

### Enter the MariaDB Command Line

Switch to the MariaDB command line with:

```bash
sudo mariadb
```

To exit the MariaDB CLI:

```sql
exit;
```

### Creating a New User

> !\[WARNING]
> Use a dedicated user per database for security.

```sql
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypassword';
```

### Creating a Database

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

### Other Useful Commands

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

### Export DB into a file

```bash
mariadb-dump -u myuser -p --no-data mydb > mydb.sql
```
