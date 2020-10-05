Sequel.migration do
  change do
    create_table(:delivery_requests) do
      primary_key :id

      String  :total_weight_in_kg,      null: false

      # assuming deliveries can be dropped off at hubs in the future
      # these attributes are not validated as required
      String  :pickup_contact_name
      String  :pickup_contact_phone
      String  :pickup_business_name
      String  :pickup_address
      String  :pickup_city
      String  :pickup_zip

      String  :dropoff_hub

      String  :invoice_contact_name,    null: false
      String  :invoice_contact_email,   null: false
      String  :invoice_business_name,   null: false
      String  :invoice_address,         null: false
      String  :invoice_city,            null: false
      String  :invoice_zip,             null: false

      Jsonb   :delivery_locations_json, null: false

      Time    :created_at,              null: false
      Time    :acknowledged_at
    end
  end
end
