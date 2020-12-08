Sequel.migration do
  change do
    add_column :deliveries, :contact_id, :integer
  end
end
