# Onyok Ambrose: CV and Portfolio Website

A personal CV and portfolio website with a Java and PostgreSQL backend and a
secure administration dashboard for managing content and appearance.

- **Frontend:** HTML5, CSS3 and vanilla JavaScript, hosted on Vercel
- **Backend:** Java 21, Spring Boot, Spring Security, Spring Data JPA, Maven, hosted on Render
- **Database:** PostgreSQL, migrated automatically with Flyway

## Project structure

```
onyok-ambrose-portfolio/
├── backend/                         Spring Boot application (Maven)
│   ├── pom.xml
│   └── src/
│       ├── main/java/com/onyokambrose/portfolio/
│       │   ├── PortfolioApplication.java
│       │   ├── config/              Security, CORS, JWT and app properties
│       │   ├── security/            Login, tokens, role checks
│       │   ├── controller/          REST endpoints (public and admin)
│       │   ├── service/             Business logic
│       │   ├── repository/          Spring Data JPA repositories
│       │   ├── entity/              JPA entities
│       │   ├── dto/                 Request and response objects
│       │   ├── exception/           Global error handling
│       │   ├── upload/              Image and PDF validation and storage
│       │   └── util/
│       ├── main/resources/
│       │   ├── application.properties
│       │   └── db/migration/        Flyway SQL migrations
│       │       ├── V1__create_schema.sql
│       │       └── V2__seed_data.sql
│       └── test/
├── frontend/                        Static site for Vercel (Stage 4 onward)
│   ├── admin/                       Administration dashboard
│   └── assets/
│       ├── css/
│       ├── js/
│       ├── images/
│       └── fonts/
├── .env.example                     Every environment variable, documented
├── .gitignore
└── README.md
```

## Status

| Stage | Description | Status |
|---|---|---|
| 1 | Project structure, Maven build, configuration | Done |
| 2 | Database schema and seed data | Migrations done and tested on PostgreSQL 16. JPA entities, repositories and services pending. |
| 3 | Administrator authentication | Pending |
| 4 | Public website (HTML, CSS, JavaScript) | Pending |
| 5 | Administration dashboard | Pending |
| 6 | REST APIs connected to every module | Pending |
| 7 | Dynamic appearance management | Pending |
| 8 | PDF CV generation | Pending |
| 9 | Full testing | Pending |
| 10 | Vercel and Render deployment | Pending |

The Java code has not been compiled yet. The build environment could not reach
Maven Central, so dependencies could not be downloaded. Run
`mvn -q clean compile` on your machine to confirm the build before continuing.

## Prerequisites

- JDK 21
- Maven 3.9 or newer (NetBeans and VS Code both include Maven support)
- PostgreSQL 14 or newer

## Set up the local database

Run these in `psql` as a superuser. Use your own password.

```sql
CREATE USER onyok WITH PASSWORD 'change-me-database-password';
CREATE DATABASE onyok_portfolio OWNER onyok;
```

Flyway creates every table on the first start, so you do not run the SQL
files by hand.

## Configure environment variables

Copy the example file and fill in your values:

```bash
cp .env.example .env
```

Never commit `.env`. It is listed in `.gitignore`.

Generate a JWT secret with:

```bash
openssl rand -base64 48
```

## Run the backend

### Terminal (any IDE)

```bash
cd backend
set -a; source ../.env; set +a      # Windows PowerShell: load each variable with $env:NAME="value"
mvn spring-boot:run
```

The API starts on http://localhost:8080. Check it with
http://localhost:8080/actuator/health, which should return `{"status":"UP"}`.

### NetBeans

1. File > Open Project, then select the `backend` folder.
2. Right-click the project > Properties > Actions, and set the environment
   variables from `.env` for the Run action.
3. Press F6 (Run Project).

### VS Code

1. Install the **Extension Pack for Java** and **Spring Boot Tools**.
2. Open the `backend` folder.
3. Create `backend/.vscode/launch.json` (this folder is git-ignored) and copy
   your values from `.env` into the `env` block:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Portfolio API",
      "request": "launch",
      "mainClass": "com.onyokambrose.portfolio.PortfolioApplication",
      "projectName": "portfolio-backend",
      "env": {
        "SPRING_DATASOURCE_URL": "jdbc:postgresql://localhost:5432/onyok_portfolio",
        "SPRING_DATASOURCE_USERNAME": "onyok",
        "SPRING_DATASOURCE_PASSWORD": "change-me-database-password",
        "JWT_SECRET": "your-generated-secret",
        "ADMIN_USERNAME": "onyok.admin",
        "ADMIN_PASSWORD": "change-me-to-a-strong-password"
      }
    }
  ]
}
```

4. Press F5, or start the app from the Spring Boot Dashboard.

The NetBeans and VS Code steps are standard workflows. They have not been
tested in those IDEs yet.

## Environment variables

| Variable | Purpose | Required |
|---|---|---|
| `SPRING_DATASOURCE_URL` | JDBC URL of the PostgreSQL database | Yes |
| `SPRING_DATASOURCE_USERNAME` | Database user | Yes |
| `SPRING_DATASOURCE_PASSWORD` | Database password | Yes |
| `JWT_SECRET` | Signs admin tokens, at least 32 characters | Yes |
| `JWT_EXPIRATION_MINUTES` | Admin session length (default 480) | No |
| `ADMIN_USERNAME` | First administrator's username | Yes, for the first start |
| `ADMIN_PASSWORD` | First administrator's password | Yes, for the first start |
| `CORS_ALLOWED_ORIGINS` | Comma-separated frontend origins | Yes in production |
| `PORT` | HTTP port (Render sets this) | No |
| `DB_POOL_SIZE` | Database connection pool size (default 5) | No |

## Design decisions

- **Images and PDFs are stored in PostgreSQL**, not on disk. Render's
  filesystem is ephemeral, so files written to disk would be lost on every
  redeploy.
- **Admin sessions use JWT bearer tokens**, not cookies. The frontend (Vercel)
  and the API (Render) are on different domains, and browsers increasingly
  block cookies across those domains.
- **Flyway owns the schema.** Hibernate only validates it (`ddl-auto=validate`),
  so the database cannot drift from the migrations.
- **Appearance and homepage sections use a draft and publish model.** The
  admin edits the draft and previews it. Only Publish copies the draft to the
  live site.
- **No public registration.** The first administrator is created from
  environment variables, and only if no admin account exists.

## Notes for Render

Render's free PostgreSQL instances expire after 30 days. Check the plan
before relying on the database for "persistent storage", and use a paid
instance or keep regular backups.
