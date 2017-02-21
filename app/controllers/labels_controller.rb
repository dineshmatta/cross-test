class LabelsController < ApplicationController

  load_and_authorize_resource :label

  def destroy
    @label.destroy

    respond_to :js
  end

  def update

    if params[:label].present? && params[:label][:name].present?
      @label.name = params[:label][:name]
    elsif params[:color].present?
      @label.color = Label::COLORS[ params[:color].to_i % Label::COLORS.count ]
    end

    @label.save

    respond_to :js
  end

  def edit
    respond_to :js
  end

  def index
    @labels = Label.viewable_by(current_user).where('name LIKE ?', "#{params[:q]}%")
    respond_to :json
  end

end
