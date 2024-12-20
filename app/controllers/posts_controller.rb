class PostsController < ApplicationController
  before_action :authenticate_user, except: [:index, :show]

  def index
    @posts = Post.all.order(:id)
    render :index
  end

  def create
    @post = Post.create(
      user_id: current_user.id,
      title: params[:title],
      body: params[:body],
      image: params[:image],
    )
    if @post.valid?
      render :show
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @post = Post.find_by(id: params[:id])
    render :show
  end

  def update
    @post = Post.find_by(id: params[:id])
    @post.update(
      title: params[:title] || @post.title,
      body: params[:body] || @post.body,
      image: params[:image] || @post.image,
    )
    if @post.valid?
      render :show
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find_by(id: params[:id])
    @post.destroy
    render json: { message: "Post successfully destroyed!" }
  end
end
