class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy secure_show_pundit]

  def index
    @tasks = policy_scope(Task)
  end

  def new
    @task = current_user.tasks.build
  end

  def show
    @task = Task.find(params[:id])

    render :show
  end

  def secure_show
    @task = current_user.tasks.find_by(id: params[:id])

    if @task
      render :show
    else
      render :show, status: :forbidden
    end
  end

  def secure_show_pundit
    authorize @task, :show?

    render :show
  end

  def edit
    authorize @task

    render :edit
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to @task, notice: 'Task was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @task

    if @task.update(task_params)
      redirect_to @task, notice: 'Task was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task

    @task.destroy!
    redirect_to tasks_url, notice: 'Task was successfully destroyed.', status: :see_other
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :user_id)
  end
end
