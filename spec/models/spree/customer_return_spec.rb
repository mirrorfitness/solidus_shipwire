describe Spree::CustomerReturn, type: :model do
  let(:shipwire_ids) { YAML.load_file('spec/fixtures/files/shipwire_order_ids.yml') }
  let(:variant_skus) { YAML.load_file('spec/fixtures/files/shipwire_variant_skus.yml') }

  # An order on Shipwire in pending state
  let(:pending_order) { shipwire_ids['pending_order'] }
  # An order on Shipwire in shipped state (contains 1*variant_1)
  let(:shipped_order_single_return_item) { shipwire_ids['shipped_order_single_return_item'] }
  # An order on Shipwire in shipped state (contains 2*variant_1 and 2*variant_2)
  let(:shipped_order_multiple_return_items) { shipwire_ids['shipped_order_multiple_return_items'] }
  # An order on Shipwire that was already been reported)
  let(:already_returned_order) { shipwire_ids['already_returned_order'] }

  let(:variant_1) { build(:variant, sku: variant_skus['sku_1']) }
  let(:variant_2) { build(:variant, sku: variant_skus['sku_2']) }

  context 'when posting a return to shipwire' do
    context 'when shipwire does not accept the return' do
      context 'when a shipwire order is in a not returnable state (Only orders that are processed and not cancelled can be returned)',
              vcr: { cassette_name: 'spree/customer_return_not_returnable' } do

        let(:customer_return) { build(:customer_return) }
        let(:inventory_unit)  { build(:inventory_unit, variant: variant_2) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { pending_order }
        let(:return_items)    { [return_item] }

        before do
          customer_return.return_items = return_items
          customer_return.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'post to shipwire' do
          expect(customer_return).to receive(:process_shipwire_return!).and_call_original

          customer_return.save
        end

        it 'add an error message' do
          customer_return.save

          expect(customer_return.errors.messages).to have_key(:shipwire_unprocessed)
          expect(customer_return.errors.messages[:shipwire_unprocessed].first).to eq("Only orders that are \"processed\" and not \"cancelled\" can be returned")
        end
      end

      context 'when a return for the order was already been reported',
              vcr: { cassette_name: 'spree/customer_return_entity_exists' } do

        let(:customer_return) { build(:customer_return) }
        let(:inventory_unit)  { build(:inventory_unit, variant: variant_1) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { already_returned_order }
        let(:return_items)    { [return_item] }

        before do
          customer_return.return_items = return_items
          customer_return.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'add an error message' do
          customer_return.save

          expect(customer_return.errors.messages).to have_key(:shipwire_already_reported)
          expect(customer_return.errors.messages[:shipwire_already_reported].first).to eq('You have already reported this issue.')
        end
      end
    end

    context 'when shipwire does accept the return' do
      context 'when return has 1 return item',
              vcr: { cassette_name: 'spree/customer_return_create_entity_single_return_item' } do

        let(:customer_return) { build(:customer_return) }
        let(:inventory_unit)  { build(:inventory_unit, variant: variant_1) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { shipped_order_single_return_item }
        let(:return_items)    { [return_item] }

        before do
          customer_return.return_items = return_items
          customer_return.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'post to shipwire' do
          expect(customer_return).to receive(:process_shipwire_return!).and_call_original
          customer_return.save
          expect(customer_return.shipwire_id).not_to be nil
        end
      end

      context 'when return has multiple return items',
              vcr: { cassette_name: 'spree/customer_return_create_entity_multiple_return_items' } do

        let(:customer_return) { build(:customer_return) }
        let(:inventory_unit_1) { build(:inventory_unit, variant: variant_1) }
        let(:inventory_unit_2) { build(:inventory_unit, variant: variant_2, order: inventory_unit_1.order) }
        let(:return_item_1) { build(:return_item, inventory_unit: inventory_unit_1) }
        let(:return_item_2) { build(:return_item, inventory_unit: inventory_unit_2) }
        let(:return_item_3) { build(:return_item, inventory_unit: inventory_unit_2) }
        let(:shipwire_id)   { shipped_order_multiple_return_items }
        let(:return_items)  { [return_item_1, return_item_2, return_item_3] }

        before do
          customer_return.return_items = return_items
          customer_return.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'post to shipwire' do
          expect(customer_return).to receive(:process_shipwire_return!).and_call_original
          customer_return.save
          expect(customer_return.shipwire_id).not_to be nil
        end
      end
    end

    context 'when generic errors occurs',
            vcr: { cassette_name: 'spree/customer_return_generic_error' } do

      let(:customer_return) { build(:customer_return) }
      let(:inventory_unit)  { build(:inventory_unit, variant: variant_1) }
      let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
      let(:shipwire_id)     { shipped_order_single_return_item }
      let(:return_items)    { [return_item] }

      before do
        customer_return.return_items = return_items
        customer_return.order.update_attribute(:shipwire_id, shipwire_id)
      end

      context 'when the response has 500 status code with included Something went wrong message' do
        it 'add a generic error' do
          customer_return.save
          expect(customer_return.errors.messages).to have_key(:shipwire_something_went_wrong)
        end
      end

      context 'when timeout occurs' do
        let(:request) { Shipwire::Request.new }

        before do
          allow(request).to receive(:build_connection)

          allow(Shipwire::Request)
            .to receive(:new)
            .with(hash_including(method: :post))
            .and_return(request)

          allow(Shipwire::Request)
            .to receive(:new)
            .with(hash_including(method: :get))
            .and_call_original

          allow(request).to receive(:make_request).and_raise(Faraday::TimeoutError)
        end

        it 'add a timeout error' do
          customer_return.save
          expect(customer_return.errors.messages).to have_key(:shipwire_timeout)
        end
      end
    end
  end
end