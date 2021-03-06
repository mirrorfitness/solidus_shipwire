module SolidusShipwire::Response
  def to_sku_id_hashmap
    Hash[body['resource']['items'].map do |v|
      [v['resource']['sku'], v['resource']['id']]
    end]
  end

  def next?
    body['resource']['next'].present?
  end

  private

  def parse_error_summary_from(body)
    if (400..599).cover?(body['status']) && body.key?('message')
      body['message']
    else
      body.fetch('error', nil).presence
    end
  end
end

Shipwire::Response.prepend SolidusShipwire::Response
