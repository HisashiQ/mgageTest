class AddErrorsCountToCampaign < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :errors_count, :integer, default: 0
  end
end
