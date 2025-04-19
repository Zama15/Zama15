# Prisma ORM notes
- [@id](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#id):
  - normal pk for a database
  - can be added with @default which uses functions(autoincrement(), cuid(), uuid(), ulid())
  - can be set String, Int, enum
  - if default was not set you must provide the ID value when creating a record
- [@@id](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#id-1):
  - define a composite pk
  - can be added with @default which uses functions(autoincrement(), cuid(), uuid(), ulid())
  - can be set String, Int, enum
  - The name of the composite ID field in Prisma Client has the following pattern: field1_field2_field3
- [@default](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#default)
  - to set a default value for a field
  - can be set for `@id` and pass a function to autogenerate ids, or pass the function now() to set a timestamp default value
- [@unique](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#unique)
  - can be optional or required
  - if there are not `@id` or `@@id` then this value must be required
- [@@unique](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#unique-1)
  - a compose unique
  - all the fields added can't be optionals
- [@relation](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#relation)
  - to define a relation database
  - first is declared the field which the PK will belong
  - construct as: FOREIGN KEY / REFERENCES
  ```
  // one-to-one relations
  model User {
    id      Int      @id @default(autoincrement())
    profile Profile?
  }

  model Profile {
    id     Int  @id @default(autoincrement())
    user   User @relation(fields: [userId], references: [id]) // the reference that link the PK
    userId Int  @unique // this is the PK
  }
  ```
  
  ```
  // one-to-many relations
  model User {
    id    Int    @id @default(autoincrement())
    posts Post[] // represents the inverse side of the one-to-many relationship. this normally is not needed in raw SQL, but here it is
  }

  model Post {
    id       Int  @id @default(autoincrement())
    author   User @relation(fields: [authorId], references: [id]) // the reference that link the PK
    authorId Int // this is the PK
  }
  ```
  
  ```
  // many-to-many relations
  model Post {
    id         Int                 @id @default(autoincrement())
    title      String
    categories CategoriesOnPosts[]
  }

  model Category {
    id    Int                 @id @default(autoincrement())
    name  String
    posts CategoriesOnPosts[]
  }

  model CategoriesOnPosts {
    post       Post     @relation(fields: [postId], references: [id]) // reference of PK
    postId     Int // PK
    category   Category @relation(fields: [categoryId], references: [id]) // reference of PK
    categoryId Int // PK
    assignedAt DateTime @default(now())
    assignedBy String

    @@id([postId, categoryId]) // make a compose id
  }
  ```
- [@updatedAt](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#updatedat)
  - automatically update the field timestamp
  - this work on a prisma level vs now() that use a database level

- [@ignore](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#ignore)[@@ignore](https://www.prisma.io/docs/orm/reference/prisma-schema-reference#ignore-1)
  - @ignore to ignore a field you do not want be modified by domain layer
  - @@ignore to ignore a model you do not want be modified by domain layer

---

# Local PostgreSQL + Prisma Setup Guide (Infrastructure Layer)

## 1. Install PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

Check the installation:

```bash
psql --version
# Example output: psql (PostgreSQL) 15.12
```

## 2. Start PostgreSQL Service

```bash
sudo systemctl start postgresql
```

## 3. Create a PostgreSQL User and Database

Create a user (name it after your username):

```bash
sudo -u postgres createuser --interactive
```

Create the development database:

```bash
sudo -u your_username createdb reuc_dev
```

Set a password:

```bash
sudo -u postgres psql
ALTER USER your_username WITH PASSWORD 'your_password';
\q
```

Verify roles and databases:

```bash
sudo -u postgres psql -c "\du"
sudo -u postgres psql -c "\l"
```

## 4. Set Up Prisma ORM

Navigate to the infrastructure layer:

```bash
cd packages/infrastructure/
```

### Install dependencies

```bash
pnpm add prisma @prisma/client
npx prisma init
```

This creates a `prisma/` folder and a `.env` file.

## 5. Configure the `.env` file

Open `.env` and update the database URL:

```dotenv
DATABASE_URL="postgresql://your_username:your_password@localhost:5432/reuc_dev?schema=public"
```

Replace `your_username` and `your_password` with your actual credentials.

## 6. Create Initial Migration

Edit `prisma/schema.prisma` with your data models (e.g. `User`, `Student`, etc), then run:

```bash
npx prisma migrate dev --name init
npx prisma generate
```

To check the tables created in the database

```bash
sudo -u your_username psql -d reuc_dev -c "\dt"
```

---

# Pull Prisma schema
## 1. Install PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

Verify installation:

```bash
psql --version
# Should show something like: psql (PostgreSQL) 15.12
```

## 2. Start the PostgreSQL Service

```bash
sudo systemctl start postgresql
```

## 3. Create a PostgreSQL User and Database

Create a user (name it after your username):

```bash
sudo -u postgres createuser --interactive
```

Create the development database:

```bash
sudo -u your_username createdb reuc_dev
```

Set a password:

```bash
sudo -u postgres psql
ALTER USER your_username WITH PASSWORD 'your_password';
\q
```

Verify roles and databases:

```bash
sudo -u postgres psql -c "\du"
sudo -u postgres psql -c "\l"
```

## 4. Configure the Project

Go to the project’s infrastructure folder:

```bash
cd packages/infrastructure/
```

Install dependencies:

```bash
pnpm install
```

Edit the `.env` file with your credentials:

```dotenv
DATABASE_URL="postgresql://your_username:your_password@localhost:5432/reuc_dev?schema=public"
```

## 5. Pull the Schema & Generate Prisma Client

Since the schema is already created and pulled from GitHub, just run:

```bash
npx prisma db pull
npx prisma generate
```

This will:
- Sync the local database with the schema
- Generate the Prisma client

---

# Making change to the scheema

Go to the project’s infrastructure folder:

```bash
cd packages/infrastructure/
```

## Before push to GitHub (solo dev)

Use:

```bash
npx prisma db push --force-reset
```

Why:
- You’re still shaping the schema
- You don’t need migration history yet
- You can freely drop/rebuild the database as needed

## After first push to GitHub (collaboration begins)

Use:

```bash
npx prisma migrate dev --name meaningful_migration_name
```

or if you need to reset everything for some reason:

```bash
npx prisma migrate reset
```

Why:
- Your teammates will **pull your schema and migration files** from GitHub
- Migrations ensure **everyone’s database evolves in sync**
- Schema changes are version-controlled

### Prisma migrate flow with teammates

When they pull your commit, they should run:

```bash
pnpm install
npx prisma migrate dev
```

This will:
- Apply all migration files in order
- Sync their DB with yours
- Regenerate the Prisma client

You need to share **just the `prisma/migrations/` folder and schema** in your repo.

---

# Use UTC consistently through layers

### `@default(now())`
This uses the **underlying database’s timezone** (PostgreSQL defaults to your system timezone unless configured).

### `@updatedAt`
This is updated **by Prisma**, and it uses **the Node.js timezone**, which is typically **UTC**.

### Set PostgreSQL to UTC

Edit `postgresql.conf`:
```bash
sudo nano /etc/postgresql/<VERSION>/main/postgresql.conf
```

Change `timezone` to UTC
```conf
timezone = 'UTC'
```

Then restart the service:
```bash
sudo systemctl restart postgresql
```

### Set Node.js and Prisma to UTC

Prisma follows the timezone of your Node.js runtime. Set Node to UTC when launching:
```bash
TZ=UTC node yourApp.js
```

Or in `.env`:
```env
TZ=UTC
```

Now both fields will now be in UTC if both your DB and Prisma are UTC-aligned.

---

# Setup Test Enviroments

Move to the infrastructure layer
```bash
cd packages/infrastructure
```

## Install development dependencies

Add the test tool and a utility for managing multiple `.env` files
```bash
pnpm add -D vitest dotenv-cli
```

Update your `package.json` with the testscript:
```json
{
  "scripts": {
    "test": "dotenv -e .env.test -- vitest run"
  }
}
```

## Prepare for testing

Create your Repo with the functions to tests
```js
// db/client.js
import { PrismaClient } from "../generated/prisma";

export const db = new PrismaClient();
```

```js
// userRepo.js
import { db } from "./db/client.js";

export const userRepo = {
  async findByEmail(email) {
    return await db.user.findUnique({
      where: { email: email },
    });
  },
  // Add more repo functions as needed ...
};
``` 

### Set Prisma Data Source to SQLite (for testing)

Edit `prisma/schema.prisma`
```
datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}
```

Make `.env.test`
```bash
mkdir .env.test
```

```ini
DATABASE_URL="file:../test.db?connection_limit=1"
TZ=UTC
```

### Generate the sqlite db
Run
```bash
pnpm prisma db push
```

### Write your tests
```
mkdir test
touch test/userRepo.test.js
```

Example test:
```js
import { describe, it, beforeAll, expect } from 'vitest'
import { db } from '../db/client.js'
import { userRepo } from '../userRepo.js'

beforeAll(async () => {
  await db.user.deleteMany() // clean slate
  await db.user.create({
    data: {
      email: 'test@example.com',
      password: '123456'
    }
  })
})

describe('userRepo', () => {
  it('should find user by email', async () => {
    const user = await userRepo.findByEmail('test@example.com')
    expect(user).toBeDefined()
    expect(user.email).toBe('test@example.com')
  })
})

```

Run the test
```bash
pnpm test
```

