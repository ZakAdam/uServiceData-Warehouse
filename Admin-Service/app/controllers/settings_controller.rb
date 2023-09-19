class SettingsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_setting, only: [:edit, :update, :destroy]

  def index
    @settings = Setting.all
  end

  def new
    @setting = Setting.new
  end

  def create
    @setting = Setting.new(setting_params)

    if @setting.save
      redirect_to settings_path, notice: 'Setting was successfully created!'
    else
      render json: { error: 'There was an error.' }.to_json, status: 400
    end
  end

  def edit
    @setting
  end

  def update
    @setting = Setting.find(params[:id])

    if @setting.update(setting_params)
      redirect_to settings_path, notice: 'JSONB data updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @setting.destroy

    redirect_to settings_path, notice: 'Setting was deleted.'
  end

  private

  def setting_params
    params.require(:setting).permit(:options, :name, :username)
  end

  def set_setting
    @setting = Setting.find(params[:id])
  end
end
