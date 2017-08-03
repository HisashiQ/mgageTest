require 'rails_helper'

RSpec.describe Campaign, type: :model do
	it 'has a valid factory' do
		campaign = build(:campaign)
		expect(campaign).to be_valid
	end

	it 'validates presence of name' do
		should validate_presence_of(:name)
	end
end