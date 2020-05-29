Sequel.migration do
  change do
    add_column :shopify_orders, :order_summary, :jsonb, default: '{}'
  end
end
