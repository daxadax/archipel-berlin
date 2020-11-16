Sequel.migration do
  change do
    drop_column :locations, :contact
    drop_column :locations, :phone
    drop_column :locations, :email

    add_column :locations, :organization_id, :integer
  end
end
