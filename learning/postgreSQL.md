# PostgreSQL Setup Guide

## Setup

```bash
pacman -S postgresql postgresql-libs
```

I always recommend using **sysz** to manage all the system services installed, so start the service with:

```bash
sysz
```

Install it with:

```bash
pacman -S sysz
```

## PostgreSQL Manage

> ![NOTE]
> I deeply believe that this is the best way to make any change, review, update, or anything related to the databases on PostgreSQL.

### Switch to the postgres user

```bash
sudo -i -u postgres
```

Then we enter the PostgreSQL command line:

```bash
psql
```

Here in the command line, we will be doing all the commands needed to manage databases.

Before starting, here is the command to exit the `psql` command line:

```sql
exit
```

or with:

```sql
\q
```

### Creating a new user

First, let’s create a new user for the database we will be creating.

> ![WARNING]
> Yes, we need a single user/role for a specific database with specific, limited permissions to ensure a more secure setup in general.

To create a new user:

```sql
CREATE ROLE myuser WITH LOGIN PASSWORD 'mypassword';
```

### Creating a database

Now, to create the database:

```sql
CREATE DATABASE mydb OWNER myuser;
```

Give permissions only to that database to the user created:

```sql
GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
```

If you want to delete your database at some point, use:

```sql
DROP DATABASE database_name;
```

### Other useful commands

Show the users/roles:

```sql
\du
```

Show the databases that exist and their owners:

```sql
\l
```

Connect to a database:

```sql
\c database_name
```

Once connected to a database, you can check its content with:

```sql
\dt
```

For a more detailed output:

```sql
\dt+
```

or:

```sql
\dt *.*
```

### Export DB into a file

```bash
pg_dump --schema-only -U myuser -d mydb > mydb.sql
```
