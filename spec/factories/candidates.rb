FactoryGirl.define do
	factory :candidate do
		name  { Faker::Name.name }
	end
end