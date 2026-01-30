---
slug: "setup-postgresql-guide"
title: "PostgreSQL Setup Guide"
description: "How to install, configure, and manage PostgreSQL, including Prisma ORM integration and troubleshooting."
tags: ["database", "postgresql", "prisma"]
date: 2025-09-08
---

## Setup

1. Install PostgreSQL

```bash
pacman -S postgresql postgresql-libs
```

2. Check the installation:

```bash
psql --version
```

3. Start the database cluster

```bash
initdb -D /var/lib/postgres/data
```

4. Start PostgreSQL Service

```bash
sudo systemctl start postgresql
```

5. Create a PostgreSQL User and Database

Create a user (recommended naming it after your username):

```bash
sudo -i -u postgres
createuser --interactive
```

## Enter the PostgreSQL Command Line

> ![NOTE]
> I deeply believe that this is the best way to make any change, review, update, or anything related to the databases on PostgreSQL.

1. Switch to the postgres user

```bash
sudo -i -u postgres
```

2. Then we enter the PostgreSQL command line:

```bash
psql
```

Here in the command line, we will be doing all the commands needed to manage databases.

## Basics of PostgreSQL

Before starting, here is the command to exit the `psql` command line:

```sql
exit
```

or with:

```sql
\q
```

First, let’s create a new user for the database we will be creating.

> ![WARNING]
> Yes, we need a single user/role for a specific database with specific, limited permissions to ensure a more secure setup in general.

To create a new user:

```sql
CREATE ROLE myuser WITH LOGIN PASSWORD 'mypassword';
```

Create the database:

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

### Useful Commands

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

## Export DB into a file

```bash
pg_dump --schema-only -U myuser -d mydb > mydb.sql
```

## Using PrismaORM

If you are using PrismaORM + PostgreSQL maybe you have run with this error while migrating the database

```bash
Environment variables loaded from .env
Prisma schema loaded from prisma/schema.prisma
Datasource "db": PostgreSQL database "DATABASE_NAME", schema "public" at "localhost:5432"

Error: P3014

Prisma Migrate could not create the shadow database. Please make sure the database user has permission to create databases. Read more about the shadow database (and workarounds) at https://pris.ly/d/migrate-shadow

Original error:
ERROR: permission denied to create database
   0: schema_core::state::DevDiagnostic
             at schema-engine/core/src/state.rs:294

 ELIFECYCLE  Command failed with exit code 1.
```

This is happening because Prisma's `migrate dev` command needs to create a second, temporary "shadow database" to check for errors before applying changes to your real `DATABASE_NAME` database.

To fix you have two options

### Make `SUPERUSER` (Recommended for Local Dev)

This is perfectly fine and easy for a local machine.

Inside the PostgreSQL command line type:

```sql
ALTER USER your_dev_user WITH SUPERUSER;
```

### Grant Minimal Permission (The "Correct" way)

If you don't want to grant full superuser, you can grant _just_ the permission Prisma is asking for.

Inside the PostgreSQL command line type:

```sql
ALTER USER your_dev_user WITH CREATEDB;
```
