Sequel.migration do
  change do
    drop_column  :delivery_requests, :delivery_ids
    add_column  :delivery_requests, :pickup_contact_id, :integer, null: false

    # NOTE: when this update is fully in place
    # make org_id required and drop invoice_location_id
    add_column  :delivery_requests, :organization_id, :integer
    add_column  :delivery_requests, :created_by_id, :integer
  end
end
