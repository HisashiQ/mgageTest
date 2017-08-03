class Vote < ApplicationRecord
	validates_presence_of :candidate_id, :campaign_id, :received_timestamp

	belongs_to :campaign
	belongs_to :candidate
end
