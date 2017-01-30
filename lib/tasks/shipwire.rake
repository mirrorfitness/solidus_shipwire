namespace :solidus_shipwire do
  desc 'Sync solidus variants in shipwire'
  task sync_variants: :environment do
    Spree::Variant.all.each(&:in_shipwire)
  end

  task link_shipwire_product: :environment do
    sku_id_hashmap = {}
    page = 0

    loop do
      limit = 20
      params ||= { limit: limit }
      params[:offset] = limit * page

      shipwire_response = Shipwire::Products.new.list(params)
      sku_id_hashmap.merge! shipwire_response.to_sku_id_hashmap

      page += 1
      break unless shipwire_response.next?
    end

    sku_id_hashmap.map do |sku, shipwire_id|
      update_shipwire_id(sku, shipwire_id)
    end

    print_results(results)
  end

  private

  def results
    @results ||= {
      updated:   {},
      skipped:   {},
      not_found: {}
    }
  end

  def update_shipwire_id(sku, shipwire_id)
    variant = Spree::Variant.find_by_sku(sku)

    if variant.present?
      update_shipwire_id_variant(variant, shipwire_id)
    else
      results[:not_found][sku] = 'not found'
    end
  end

  def update_shipwire_id_variant(variant, shipwire_id)
    if variant.shipwire_id.nil?
      variant.update_attribute(:shipwire_id, shipwire_id)
      results[:updated][variant.sku] = 'ok'
    elsif variant.shipwire_id != shipwire_id
      results[:skipped][variant.sku] = 'already linked'
    else
      results[:skipped][variant.sku] = 'same'
    end
  end

  def print_results(results)
    results.each do |k, v|
      puts k
      puts v
    end
  end
end