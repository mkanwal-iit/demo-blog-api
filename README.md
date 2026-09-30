# Demo Blog API

A RESTful JSON API for a blogging platform, built with **Ruby on Rails 8.1** and **PostgreSQL**.
Supports user registration, session-based authentication, and full CRUD on blog posts.

![CI](https://github.com/mkanwal-iit/demo-blog-api/actions/workflows/ci.yml/badge.svg)

**Live API:** [demo-blog-api-q9rt.onrender.com](https://demo-blog-api-q9rt.onrender.com) —
try [`/posts`](https://demo-blog-api-q9rt.onrender.com/posts) for seeded sample data.

> Hosted on Render's free tier, which sleeps after 15 minutes of inactivity.
> The first request after a sleep takes roughly 30 seconds to wake the container.

---

## Features

- **User accounts** — registration with securely hashed passwords (`bcrypt` via `has_secure_password`)
- **Authentication** — login and logout through session endpoints
- **Posts** — create, read, update, and delete blog posts, each belonging to a user
- **Automated CI** — every push runs tests, a security scan, a dependency audit, and a style check

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Framework | Ruby on Rails 8.1 |
| Language | Ruby 3.3.4 |
| Database | PostgreSQL |
| Testing | Minitest |
| Security scanning | Brakeman |
| Linting | RuboCop (`rubocop-rails-omakase`) |
| Containerization | Docker |
| CI | GitHub Actions |

---

## API Endpoints

### Users
| Method | Endpoint | Description |
| --- | --- | --- |
| `POST` | `/users` | Register a new user |

### Sessions
| Method | Endpoint | Description |
| --- | --- | --- |
| `POST` | `/sessions` | Log in |
| `DELETE` | `/sessions` | Log out |

### Posts
| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/posts` | List all posts |
| `POST` | `/posts` | Create a post |
| `GET` | `/posts/:id` | Fetch a single post |
| `PATCH` | `/posts/:id` | Update a post |
| `DELETE` | `/posts/:id` | Delete a post |

### Health
| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/up` | Health check — returns 200 if the app boots cleanly |

---

## Data Model

```
User                          Post
├── name                      ├── user_id  → User
├── email                     ├── title
├── password_digest           ├── body
├── created_at                ├── image
└── updated_at                ├── created_at
                              └── updated_at
```

---

## Getting Started

### Prerequisites
- Ruby 3.3.4
- PostgreSQL
- Bundler

### Setup

```bash
git clone https://github.com/mkanwal-iit/demo-blog-api.git
cd demo-blog-api

bundle install          # install dependencies
bin/rails db:create     # create the database
bin/rails db:migrate    # run migrations
bin/rails server        # start on http://localhost:3000
```

### Example request

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Ada", "email": "ada@example.com", "password": "secret123"}'
```

---

## Development

```bash
bin/rails test          # run the test suite
bin/rubocop             # check code style
bin/brakeman            # scan for security vulnerabilities
```

### Docker

```bash
docker build -t demo-blog-api .
docker run -p 3000:3000 demo-blog-api
```

---

## Deployment

Deployed to [Render](https://render.com) as a Docker service, built from the
`Dockerfile` in this repository. Pushes to `main` trigger an automatic redeploy.

**Configuration** is supplied entirely through environment variables, so the same
image runs unchanged locally, in CI, and in production:

| Variable | Purpose |
| --- | --- |
| `DATABASE_URL` | PostgreSQL connection string; Rails merges it over `config/database.yml` |
| `RAILS_ENV` | `production` |
| `SECRET_KEY_BASE` | Signs session cookies so they cannot be forged |

**Startup** runs through [`bin/docker-entrypoint`](bin/docker-entrypoint), which applies
migrations and seeds before booting Puma. Seeding runs explicitly because `db:prepare`
only seeds a database it creates itself; `db/seeds.rb` is idempotent, so repeating it on
every boot is safe.

---

## Continuous Integration

Every push to `main` and every pull request triggers [`.github/workflows/ci.yml`](.github/workflows/ci.yml),
which runs four jobs in parallel:

| Job | Purpose |
| --- | --- |
| `test` | Runs the Minitest suite against a live PostgreSQL service container |
| `scan_ruby` | Brakeman static analysis for Rails security vulnerabilities |
| `scan_js` | Audits JavaScript dependencies for known CVEs |
| `lint` | Enforces consistent style with RuboCop |

### What the first run caught

The workflow file shipped with the project but had never executed — nothing had been
pushed to `main` since it was added. Getting it to run surfaced five issues:

**1. Every job failed at setup.** The workflow reads the Ruby version from
`.ruby-version`, and that file did not exist. Pinned it to 3.3.4 to match the
`RUBY_VERSION` already declared in the Dockerfile.

**2. A stale test assertion.** `GET /posts/:id` asserted an exact list of six JSON
keys, but the response included a seventh — `owner`, defined in
`app/views/posts/_post.json.jbuilder` as `post.user == current_user` so the frontend
knows whether to show edit controls. The field was intentional and the test predated
it, so the expectation was updated rather than the response.

**3. Eight RuboCop offenses**, all `Layout/SpaceInsideArrayLiteralBrackets`.
Resolved with `rubocop -a`.

**4. Rails 7.2 was end-of-life.** Brakeman's `EOLRails` check flagged that support
ended 2026-08-09, so the framework was no longer receiving security patches.
Upgraded to Rails 8.1.4; the full suite passed unchanged.

**5. Brakeman failing on its own version.** After the upgrade the scan still failed,
while `bundle exec brakeman` passed locally. The cause was `bin/brakeman`, which
injects `--ensure-latest` into every invocation — so the pinned 6.2.2 failed for being
outdated, not for anything in the application. Upgrading the gem to 8.0.6 cleared it.

The repository also had no `.gitignore`, so `tmp/` and `log/` were not excluded from
version control. Added the standard Rails ignore file and untracked those directories.
