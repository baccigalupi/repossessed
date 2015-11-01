class Schema < ActiveRecord::Migration
  def change
    create_table :users, force: true do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password
      t.string :dob
    end

    create_table :program_configurations, force: true do |t|
      t.integer :program_id
      t.string :type
      t.string :_value
    end

    create_table :greeters, force: true do |t|
      t.string :hello
    end
  end
end
