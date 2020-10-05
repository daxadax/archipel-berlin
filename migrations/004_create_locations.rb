Sequel.migration do
  change do
    create_table(:locations) do
      primary_key :id

      String  :name,            null: false
      String  :address,         null: false
      String  :city,            null: false
      String  :zip,             null: false
      String  :contact,         null: false

      String  :opening_hours
      String  :opening_days
      String  :phone
      String  :email

      Time    :created_at,      null: false
    end
  end
end
