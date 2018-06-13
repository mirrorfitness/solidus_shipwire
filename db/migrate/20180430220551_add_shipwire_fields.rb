class AddShipwireFields < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_variants, :shipwire_id, :integer, default: nil, null: true
    add_column :spree_orders, :shipwire_id, :integer, default: nil, null: true
    add_column :spree_stock_locations, :shipwire_id, :string
    add_column :spree_return_authorizations, :shipwire_id, :integer, default: nil, null: true
  end
end
