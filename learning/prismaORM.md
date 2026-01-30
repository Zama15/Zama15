---
slug: "prisma-orm-notes"
title: "Prisma ORM Notes"
description: "Personal notes on Prisma schema references, relations, and setting up a local infrastructure with testing."
tags: ["database", "postgresql", "prisma"]
date: 2025-04-16
---

## Examples of schema.prisma

- one-to-one relations

```
model User {
  id      Int      @id @default(autoincrement())

  profile Profile?
}

model Profile {
  id     Int  @id @default(autoincrement())
  userId Int  @unique

  user   User @relation(fields: [userId], references: [id])
}
```

- one-to-many relations

```
model User {
  id    Int    @id @default(autoincrement())

  posts Post[]
}

model Post {
  id       Int  @id @default(autoincrement())
  authorId Int

  author   User @relation(fields: [authorId], references: [id])
}
```

- many-to-many relations

```
model Post {
  id    Int    @id @default(autoincrement())
  title String

  categories CategoriesOnPosts[]
}

model Category {
  id   Int    @id @default(autoincrement())
  name String

  posts CategoriesOnPosts[]
}

model CategoriesOnPosts {
  postId     Int
  categoryId Int
  assignedAt DateTime @default(now())

  post       Post     @relation(fields: [postId], references: [id])
  category   Category @relation(fields: [categoryId], references: [id])

  @@id([postId, categoryId])
}
```

## Setting Up From Scratch for Local

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

6. Create the development database:

```bash
sudo -u your_username createdb my_db
```

7. Set a password:

```bash
sudo -u postgres psql
ALTER USER your_username WITH PASSWORD 'your_password';
\q
```

8. Verify roles and databases:

```bash
sudo -u postgres psql -c "\du"
sudo -u postgres psql -c "\l"
```

9. Navigate to the path of the project

```bash
cd path/to/project/
```

10. Install dependencies

```bash
pnpm add prisma @prisma/client
npx prisma init
```

This creates a `prisma/` folder and a `.env` file.

11. Configure the `.env` file

Open `.env` and update the database URL:

```dotenv
DATABASE_URL="postgresql://your_username:your_password@localhost:5432/my_db?schema=public"
```

Replace `your_username`, `your_password` and `my_db` with your actual credentials.

12. Create Initial Migration

Edit `prisma/schema.prisma` with your data models (e.g. `User`, `Student`, etc), then run:

```bash
npx prisma migrate dev --name init
npx prisma generate
```

To check the tables created in the database

```bash
sudo -u your_username psql -d my_db -c "\dt"
```

## Pulling from Scratch Schema Projects

Reapeat the steps 1 to 9 from [above](#setting-up-from-scratch-for-local)

1. Install dependencies:

```bash
pnpm install
```

Edit the `.env` file with your credentials:

```dotenv
DATABASE_URL="postgresql://your_username:your_password@localhost:5432/reuc_dev?schema=public"
```

2. Pull the Schema & Generate Prisma Client

Since the schema is already created and pulled from GitHub, just run:

```bash
npx prisma db pull
npx prisma generate
```

This will:

- Sync the local database with the schema
- Generate the Prisma client

## Pushing schema.prisma to Local Database

Go to the project’s folder:

```bash
cd path/to/project
```

### Before push to GitHub (solo dev)

Use:

```bash
npx prisma db push --force-reset
```

Why:

- You’re still shaping the schema
- You don’t need migration history yet
- You can freely drop/rebuild the database as needed

### After first push to GitHub (collaboration begins)

Use:

```bash
npx prisma migrate dev --name meaningful_migration_name
```

Why:

- Your teammates will **pull your schema and migration files** from GitHub
- Migrations ensure **everyone’s database evolves in sync**
- Schema changes are version-controlled

## Pulling schema.prisma to Local Database

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
