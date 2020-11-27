Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      foreign_key :organization_id

      String    :external_id,     null: false
      String    :email,           null: false
      String    :nickname
      String    :password_digest, null: false
      TrueClass :administrator,   default: false
      TrueClass :super_user,      default: false

      Time      :created_at,      null: false
    end
  end
end
