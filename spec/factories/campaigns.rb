FactoryGirl.define do
	factory :campaign do
		name     { Faker::Name.name }
		errors_count {Faker::Number.number(3) }
	end
end