Sequel.migration do
  change do
    create_table(:deliveries) do
      primary_key :id

      Integer :delivery_request_id, null: false
      Integer :location_id,         null: false

      Time    :available_from,      null: false
      Time    :deadline,            null: false
      Time    :created_at,          null: false
    end
  end
end
