json.extract! sale, :id, :name, :description, :amount, :printed, :paid, :payee, :created_at, :updated_at
json.url sale_url(sale, format: :json)
