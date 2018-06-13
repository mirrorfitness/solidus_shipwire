Spree::LineItem.class_eval do
  scope :on_shipwire, -> { base.joins(:variant).where.not(spree_variants: { shipwire_id: nil })  }

  def to_shipwire
    {
      sku: sku,
      quantity: quantity,
      commercialInvoiceValue: price,
      commercialInvoiceValueCurrency: 'USD'
    }
  end
end
