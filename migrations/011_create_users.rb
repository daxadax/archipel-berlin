Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      foreign_key :organization_id

      String    :email,           null: false
      String    :password_digest, null: false
      TrueClass :administrator,   default: false

      Time      :created_at,      null: false
    end
  end
end
