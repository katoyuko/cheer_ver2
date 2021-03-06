class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :show, :edit, :update, :destroy]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def top
    # post_categoriesとpostsを内部統合 一週間単位でcount
    post_category_count = PostCategory.joins(:posts).where(created_at: 1.months.ago..Time.now).group(:post_category_id).count
    # 配列をハッシュに変換 要素の順番を並び替え ハッシュのキーを取得
    post_category_ids = Hash[post_category_count.sort_by{ |_, v| -v }].keys
    # 投稿数多い順 4つのカテゴリをホットなカテゴリとして表示
    @post_category_ranks = PostCategory.where(id: post_category_ids).sort_by{|o| post_category_ids.index(o.id)}[0..3]

    # お気に入りカテゴリ一覧
    if @user = current_user
      @favorite_categories = @user.favorite_categories.page(params[:page]).order(created_at: :desc).limit(4)
    end

    @post_categories = PostCategory.all
  end

  def about
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.post_category_id = params[:post_category_id]
    @post.user_id = current_user.id

    if @post.save
      redirect_to posts_path, notice: "投稿しました！"
    else
      render :new
    end
  end

  def index
    @posts = Post.page(params[:page]).reverse_order.per(16)
  end

  def show
    @post_comment = PostComment.new
  end

  def edit
    if @post.user_id != current_user.id
      redirect_to root_path
    end
  end

  def update
    if @post.update(post_params)
      redirect_to posts_path, notice: "更新しました！"
    else
      render :edit
    end
  end

  def destroy
    if @post.destroy
      redirect_to user_path(current_user), notice: "削除しました！"
    else
      renser :edit
    end
  end

  private
    def post_params
      params.require(:post).permit(:post_category_id, :image, :post_content, :user_id)
    end

    def set_post
      @post = Post.find(params[:id])
    end

end

