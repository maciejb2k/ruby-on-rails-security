class ArticlesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @result_article = Article.new(param1: 'param1', param2: '')

    # RCE poprzez funkcję `open`
    if params[:url]
      @result_article.param1 = 'params[:url]'
      @result_article.param2 = open(params[:url])
    end

    # RCE poprzez `send`
    if params[:send_method_name] && params[:send_argument]
      @result_article.param1 = "#{params[:send_method_name]}, #{params[:send_argument]}"
      begin
        @result_article.param2 = @result_article.send(params[:send_method_name], params[:send_argument])
      rescue StandardError => e
        @result_article.param2 = e.message
      end
    end

    # RCE poprzez deserializację Marshal
    if params[:base64binary]
      @result_article.param1 = params[:base64binary]
      @result_article.param2 = Marshal.load(Base64.decode64(params[:base64binary]))
    end

    # RCE poprzez YAML deserializację
    if params[:yaml]
      @result_article.param2 = YAML.unsafe_load(params[:yaml])
    end
  end
end
