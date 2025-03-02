class UnsafeArticlesController < ApplicationController
  skip_forgery_protection

  before_action :set_unsafe_article, only: %i[show edit update destroy]

  # GET /unsafe_articles
  def index
    @unsafe_articles = UnsafeArticle.all
  end

  # GET /unsafe_articles/1
  def show
  end

  # GET /unsafe_articles/new
  def new
    @unsafe_article = UnsafeArticle.new
  end

  # GET /unsafe_articles/1/edit
  def edit
  end

  # POST /unsafe_articles
  def create
    @unsafe_article = UnsafeArticle.new(unsafe_article_params)

    if @unsafe_article.save
      redirect_to @unsafe_article, notice: 'Unsafe article was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /unsafe_articles/1
  def update
    if @unsafe_article.update(unsafe_article_params)
      redirect_to @unsafe_article, notice: 'Unsafe article was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /unsafe_articles/1
  def destroy
    @unsafe_article.destroy!
    redirect_to unsafe_articles_url, notice: 'Unsafe article was successfully destroyed.', status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_unsafe_article
    @unsafe_article = UnsafeArticle.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def unsafe_article_params
    params.require(:unsafe_article).permit(:title, :content)
  end
end
