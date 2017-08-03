class Campaign < ApplicationRecord
	validates_presence_of :name

	has_many :votes
	has_many :candidates, -> { distinct }, through: :votes
end
