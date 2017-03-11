json.extract! claim, :id, :name, :description, :amount, :created_at, :updated_at
json.url claim_url(claim, format: :json)
