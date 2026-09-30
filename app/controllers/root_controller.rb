class RootController < ApplicationController
  # Serves a plain index of the API at "/" so the bare URL is useful rather
  # than a 404 for anyone opening the deployed link.
  def index
    render json: {
      name: "Demo Blog API",
      description: "A RESTful JSON API for a blogging platform, built with Ruby on Rails.",
      source: "https://github.com/mkanwal-iit/demo-blog-api",
      endpoints: {
        "GET /posts": "List all posts",
        "POST /posts": "Create a post (requires authentication)",
        "GET /posts/:id": "Fetch a single post",
        "PATCH /posts/:id": "Update a post (requires authentication)",
        "DELETE /posts/:id": "Delete a post (requires authentication)",
        "POST /users": "Register a new user",
        "POST /sessions": "Log in",
        "DELETE /sessions": "Log out",
        "GET /up": "Health check"
      }
    }
  end
end
