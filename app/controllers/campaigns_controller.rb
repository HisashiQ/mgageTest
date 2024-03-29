class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show]

  def index
    @campaigns = Campaign.all
  end

  def show
    @candidates = @campaign.candidates
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_params
      params.require(:campaign).permit(:name)
    end
end
