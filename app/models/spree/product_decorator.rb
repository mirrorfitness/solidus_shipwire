Spree::Product.class_eval do
  delegate :shipwire_id, :shipwire_id=, to: :find_or_build_master
end
