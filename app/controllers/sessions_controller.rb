class SessionsController < ApplicationController
  def new
  end

  def create
    adapter = DataAdapter.current
    user = adapter.find_user_by_credentials(params[:username], params[:password])

    if user
      session[:user_id] = user.id
      redirect_to habits_path
    else
      flash.now[:alert] = "Invalid username or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
