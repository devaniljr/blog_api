# Posts API

API for creating posts, rating them, and analyzing IP usage patterns.

## Setup

```bash
bundle install
rails db:create db:migrate
```

## Run

```bash
rails server
```

## Seed

Generates 200k posts, 100 users, and 150k ratings using the API controllers via Rack.

```bash
rails db:seed
```

A curl-based alternative is in `lib/scripts/seed.sh`.

## Endpoints

### POST /api/v1/posts

Creates a post. If the user doesn't exist, it's created automatically.

```json
{ "title": "Post title", "body": "Content", "login": "username", "ip": "1.2.3.4" }
```

Returns the post and user on success (201), or validation errors (422).

### POST /api/v1/ratings

Rates a post. Each user can rate a post only once.

```json
{ "post_id": 1, "user_id": 5, "value": 4 }
```

Returns the rating and the post's average rating.

### GET /api/v1/posts/top

Returns the top N posts by average rating. Default is 10.

```
GET /api/v1/posts/top?n=5
```

Posts without ratings are not included.

### GET /api/v1/ips

Lists all IPs and the logins of authors who posted from each one.

```json
[{ "ip": "1.2.3.4", "logins": ["user_a", "user_b"] }]
```

## Testing

```bash
bundle exec rspec
```

## Linting

```bash
bundle exec rubocop
```
