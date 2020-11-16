Sequel.migration do
  change do
    create_table(:organizations) do
      primary_key :id

      # NOTE: this address information will be used for invoices
      String  :name,        null: false
      String  :address,     null: false
      String  :city,        null: false
      String  :zip,         null: false

      Time    :created_at,  null: false
    end
  end
end
