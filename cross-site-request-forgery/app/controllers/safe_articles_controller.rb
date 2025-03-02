class SafeArticlesController < ApplicationController
  before_action :set_safe_article, only: %i[show edit update destroy]

  # GET /safe_articles
  def index
    @safe_articles = SafeArticle.all
  end

  # GET /safe_articles/1
  def show
  end

  # GET /safe_articles/new
  def new
    @safe_article = SafeArticle.new
  end

  # GET /safe_articles/1/edit
  def edit
  end

  # POST /safe_articles
  def create
    @safe_article = SafeArticle.new(safe_article_params)

    if @safe_article.save
      redirect_to @safe_article, notice: 'Safe article was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /safe_articles/1
  def update
    if @safe_article.update(safe_article_params)
      redirect_to @safe_article, notice: 'Safe article was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /safe_articles/1
  def destroy
    @safe_article.destroy!
    redirect_to safe_articles_url, notice: 'Safe article was successfully destroyed.', status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_safe_article
    @safe_article = SafeArticle.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def safe_article_params
    params.require(:safe_article).permit(:title, :content)
  end
end
