class Candidate < ApplicationRecord
	validates_presence_of :name

	has_many :votes
	has_many :campaigns, -> { distinct }, through: :votes
end
