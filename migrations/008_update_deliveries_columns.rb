Sequel.migration do
  change do
    drop_column :deliveries, :deadline
    add_column :deliveries, :notes, :text
  end
end
