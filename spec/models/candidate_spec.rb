require 'rails_helper'

RSpec.describe Candidate, type: :model do
	it 'has a valid factory' do
		candidate = build(:candidate)
		expect(candidate).to be_valid
	end

	it 'validates presence of name' do
		should validate_presence_of(:name)
	end
end