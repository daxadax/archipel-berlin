Sequel.migration do
  change do
    create_table(:contacts) do
      primary_key :id
      foreign_key :location_id

      String  :name, null: false
      String  :email
      String  :phone

      Time    :created_at,      null: false
    end
  end
end
