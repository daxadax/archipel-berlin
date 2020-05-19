Sequel.migration do
  change do
    create_table(:shopify_orders) do
      primary_key :id

      Date    :date,              null: false, unique: true
      Text    :csv_string,        null: false
      String  :uploaded_by,       null: false
      Bytea   :generated_reports

      Time    :created_at,        null: false
    end
  end
end
