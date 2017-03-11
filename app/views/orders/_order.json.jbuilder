json.extract! order, :id, :name, :description, :price, :quantity, :supplier, :link, :part_number, :created_at, :updated_at
json.url order_url(order, format: :json)
