require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post "/users.json", params: { name: "Test", email: "test@example.com", password: "password" }
    post "/sessions.json", params: { email: "test@example.com", password: "password" }
  end

  test "index" do
    get "/posts.json"
    assert_response 200

    data = JSON.parse(response.body)
    assert_equal Post.count, data.length
  end

  test "create" do
    assert_difference "Post.count", 1 do
      post "/posts.json", params: { title: "Test title", image: "test.jpg", body: "Test body" }
      assert_response 200
    end

    assert_difference "Post.count", 0 do
      post "/posts.json", params: {}
      assert_response 422
    end

    assert_difference "Post.count", 0 do
      cookies.delete("user_id")
      post "/posts.json", params: { title: "Test title", image: "test.jpg", body: "Test body" }
      assert_response 401
    end
  end

  test "show" do
    get "/posts/#{Post.first.id}.json"
    assert_response 200

    data = JSON.parse(response.body)
    assert_equal ["id", "title", "image", "body", "created_at", "updated_at"], data.keys
  end

  test "update" do
    post = Post.first
    patch "/posts/#{post.id}.json", params: { title: "Updated title" }
    assert_response 200

    data = JSON.parse(response.body)
    assert_equal "Updated title", data["title"]

    patch "/posts/#{post.id}.json", params: { title: "" }
    assert_response 422

    cookies.delete("user_id")
    patch "/posts/#{post.id}.json", params: { title: "Updated title" }
    assert_response 401
  end

  test "destroy" do
    assert_difference "Post.count", -1 do
      delete "/posts/#{Post.first.id}.json"
      assert_response 200
    end

    assert_difference "Post.count", 0 do
      cookies.delete("user_id")
      delete "/posts/#{Post.first.id}.json"
      assert_response 401
    end
  end
end
