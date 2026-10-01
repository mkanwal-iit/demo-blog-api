Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Browsers block cross-origin requests unless the API names the calling
    # origin here. localhost:5173 is the Vite dev server; the onrender.com host
    # is the deployed frontend.
    origins "localhost:5173", "https://blog-typescript-frontend.onrender.com"
    resource "*", headers: :any, credentials: true, methods: [ :get, :post, :patch, :put, :delete ]
  end
end
