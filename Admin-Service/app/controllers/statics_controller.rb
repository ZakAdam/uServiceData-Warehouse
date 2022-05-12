class StaticsController < ApplicationController
  def home
    @logs = Log.all.order(started_at: :desc).limit(100)
  end
end
