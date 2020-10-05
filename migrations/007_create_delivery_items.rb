Sequel.migration do
  change do
    create_table(:delivery_items) do
      primary_key :id
      Integer :delivery_id,     null: false

      String  :name,            null: false
      Integer :weight_in_grams, null: false
      String  :notes

      Time    :created_at,      null: false
    end
  end
end
