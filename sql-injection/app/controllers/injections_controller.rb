class InjectionsController < ApplicationController
  ##
  # 1. Calculation method
  #
  #   params[:column] = "age) FROM users WHERE name = 'Bob';"
  #   Order.calculate(:sum, params[:column])
  #
  def calculation
    @result = nil
    @queries = []

    return unless request.post?

    @column = params[:column]

    begin
      @queries = capture_sql do
        @result = Order.calculate(:sum, @column)
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 2. Delete By Method
  #
  #   params[:id] = "1) OR 1=1--"
  #   User.delete_by("id = #{params[:id]}")
  #
  def delete_by
    @result = nil
    @queries = []

    return unless request.post?

    @id = params[:id]
    begin
      @queries = capture_sql do
        @result = User.delete_by("id = #{@id}")
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 3. Destroy By Method
  #
  #   params[:admin] = "') OR 1=1--'"
  #   User.destroy_by(["id = ? AND admin = '#{params[:admin]}'", params[:id]])
  #
  def destroy_by
    @result = nil
    @queries = []

    return unless request.post?

    @admin = params[:admin]
    @id    = params[:id]
    begin
      @queries = capture_sql do
        # UWAGA: w przykładzie oryginalnym brakuje param[:id],
        # dopisałem aby było co wstawić w klauzule "id = ?"
        @result = User.destroy_by(["id = ? AND admin = '#{@admin}'", @id])
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 4. Exists? Method
  #
  #   User.exists?(params[:user])
  #   -> SELECT 1 AS one FROM ...
  #
  #   params[:user] = "') or (SELECT 1 AS one FROM 'orders' WHERE total > 100 AND ''='"
  #   User.exists?(["name = '#{params[:user]}'"])
  #
  def exists
    @result = nil
    @queries = []

    return unless request.post?

    @user_param = params[:user]
    begin
      @queries = capture_sql do
        # Prosty wariant:
        # @result = User.exists?(@user_param)

        # Bardziej "złożony" jak w przykładzie:
        @result = User.exists?(["name = '#{@user_param}'"])
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 5. Find By Method
  #
  #   params[:id] = "admin = '1'"
  #   User.find_by params[:id]
  #
  def find_by
    @result = nil
    @queries = []

    return unless request.post?

    @id_param = params[:id_param]
    begin
      @queries = capture_sql do
        @result = User.find_by(@id_param) # find_by("admin = '1'")
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 6. From Method
  #
  #   params[:from] = "users WHERE admin = '1' OR ''=?;"
  #   User.from(params[:from]).where(admin: false).all
  #
  def from
    @result = nil
    @queries = []

    return unless request.post?

    @from_param = params[:from_param]
    begin
      @queries = capture_sql do
        @result = User.from(@from_param).where(admin: false).to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 7. Group Method
  #
  #   params[:group] = "name UNION SELECT * FROM users"
  #   User.where(admin: false).group(params[:group])
  #
  def group
    @result = nil
    @queries = []

    return unless request.post?

    @group_param = params[:group_param]
    begin
      @queries = capture_sql do
        # Wywołanie .to_a aby faktycznie wykonać zapytanie
        @result = User.where(admin: false).group(@group_param).to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 8. Having Method
  #
  #   params[:total] = "1) UNION SELECT * FROM orders--"
  #   Order.where(user_id: 1).group(:user_id).having("total > #{params[:total]}")
  #
  def having
    @result = nil
    @queries = []

    return unless request.post?

    @total = params[:total]
    begin
      @queries = capture_sql do
        @result = Order.where(user_id: 1).group(:id, :user_id).having("total > #{@total}").to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 9. Joins Method
  #
  #   params[:table] = "--"
  #   Order.joins(params[:table]).where("total > 1000").all
  #
  def joins
    @result = nil
    @queries = []

    return unless request.post?

    @table_param = params[:table_param]
    begin
      @queries = capture_sql do
        @result = Order.joins(@table_param).where('total > 100').to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 10. Lock Method + option
  #
  #   params[:lock] = "?"
  #   User.where("id > 1").lock(params[:lock])
  #
  def lock
    @result = nil
    @queries = []

    return unless request.post?

    @lock_param = params[:lock_param]
    begin
      @queries = capture_sql do
        @result = User.where('id > 1').lock(@lock_param).to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 11. Not Method
  #
  #   params[:excluded] = "?)) OR 1=1 --"
  #   User.where.not("admin = 1 OR id IN (#{params[:excluded]})").all
  #
  def not
    @result = nil
    @queries = []

    return unless request.post?

    @excluded = params[:excluded]
    begin
      @queries = capture_sql do
        @result = User.where.not("admin = true OR id IN (#{@excluded})").to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 12. Select Method
  #
  #   params[:column] = "* FROM users WHERE admin = '1' ;"
  #   User.select(params[:column])
  #
  def select
    @result = nil
    @queries = []

    return unless request.post?

    @column = params[:column]
    begin
      @queries = capture_sql do
        @result = User.select(@column).to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 13. Reselect Method
  #
  #   params[:column] = "* FROM orders -- "
  #   User.select(:name).reselect(params[:column])
  #
  def reselect
    @result = nil
    @queries = []

    return unless request.post?

    @column = params[:column]
    begin
      @queries = capture_sql do
        @result = User.select(:name).reselect(@column).to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 14. Where Method
  #
  #   params[:name] = "') OR 1--"
  #   User.where("name = '#{params[:name]}' AND password = '#{params[:password]}'")
  #
  def where
    @result = nil
    @queries = []

    return unless request.post?

    @name = params[:name]
    @password = params[:password]
    begin
      @queries = capture_sql do
        @result = User.where("name = '#{@name}' AND password = '#{@password}'").to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 15. Rewhere Method
  #
  #   params[:age] = "1=1) OR 1=1--"
  #   User.where(name: "Bob").rewhere("age > #{params[:age]}")
  #
  def rewhere
    @result = nil
    @queries = []

    return unless request.post?

    @age = params[:age]
    begin
      @queries = capture_sql do
        @result = User.where(name: 'Bob').rewhere("age > #{@age}").to_a
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  ##
  # 16. Update All Method
  #
  #   params[:name] = "' OR 1=1;"
  #   User.update_all("admin = 1 WHERE name LIKE '%#{params[:name]}%'")
  #
  def update_all
    @result = nil
    @queries = []

    return unless request.post?

    @name = params[:name]
    begin
      @queries = capture_sql do
        @result = User.update_all("admin = true WHERE name LIKE '%#{@name}%'")
      end
    rescue StandardError => e
      @error = e.message
    end
  end

  def reset_db
    begin
      Rails.application.load_seed
      flash[:notice] = "Baza danych została ponownie zainicjalizowana."
    rescue StandardError => e
      flash[:alert] = "Błąd podczas seedowania: #{e.message}"
    end

    redirect_back fallback_location: root_path
  end

  private

  def capture_sql
    queries = []

    subscription = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      sql = payload[:sql]

      next if sql =~ /BEGIN/i
      next if sql =~ /COMMIT/i
      next if sql =~ /ROLLBACK/i
      next if sql.include?('pg_attribute')
      next if sql.include?('pg_type')
      next if sql.include?('pg_class')
      next if sql.include?('sqlite_master')
      next if sql.include?('SHOW search_path')

      queries << sql
    end

    yield

    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscription)
  end
end
