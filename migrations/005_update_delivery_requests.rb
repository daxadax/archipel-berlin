Sequel.migration do
  change do
    drop_column :delivery_requests, :total_weight_in_kg

    drop_column :delivery_requests, :pickup_contact_name
    drop_column :delivery_requests, :pickup_contact_phone

    drop_column :delivery_requests, :pickup_business_name
    drop_column :delivery_requests, :pickup_address
    drop_column :delivery_requests, :pickup_city
    drop_column :delivery_requests, :pickup_zip

    drop_column :delivery_requests, :invoice_contact_name
    drop_column :delivery_requests, :invoice_contact_email
    drop_column :delivery_requests, :invoice_business_name
    drop_column :delivery_requests, :invoice_address
    drop_column :delivery_requests, :invoice_city
    drop_column :delivery_requests, :invoice_zip

    drop_column :delivery_requests, :delivery_locations_json

    add_column  :delivery_requests, :pickup_location_id,  :integer, null: false
    add_column  :delivery_requests, :invoice_location_id, :integer, null: false
    add_column  :delivery_requests, :delivery_ids, 'text[]', default: []
  end
end
