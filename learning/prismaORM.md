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

---

## 2. Start PostgreSQL Service

```bash
sudo systemctl start postgresql
```

---

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

---

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

---

## 5. Configure the `.env` file

Open `.env` and update the database URL:

```dotenv
DATABASE_URL="postgresql://your_username:your_password@localhost:5432/reuc_dev?schema=public"
```

Replace `your_username` and `your_password` with your actual credentials.

---

## 6. Create Initial Migration

Edit `prisma/schema.prisma` with your data models (e.g. `User`, `Student`, etc), then run:

```bash
npx prisma migrate dev --name init
npx prisma generate
```

---

Done! You're now ready to use Prisma with PostgreSQL locally.

