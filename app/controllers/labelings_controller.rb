class LabelingsController < ApplicationController

  load_and_authorize_resource :labeling

  def create
    @labeling = Labeling.create(labeling_params)

    respond_to :js
  end

  def destroy
    @labelings = Labeling.find(params[:id])

    @labelings.destroy

    respond_to :js
  end

  protected
    def labeling_params
      params.require(:labeling).permit(
          :label_id,
          :labelable_id,
          :labelable_type,
          label: [
              :name
          ]
      )
    end
end
