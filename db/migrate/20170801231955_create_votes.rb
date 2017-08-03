class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :votes do |t|
      t.datetime :received_timestamp
      t.belongs_to :candidate, index: true
      t.belongs_to :campaign, index: true
      t.timestamps
    end
  end
end
