tenant1 = Tenant.find_or_create_by!(name: Tenant::DEFAULT_TENANT)
tenant2 = Tenant.find_or_create_by!(name: "tenant2")

User.find_or_create_by!(email: "user1@test.org") do |user|
  user.tenant = tenant1
  user.password = "user1@test.org"
  user.password_confirmation = "user1@test.org"
end

User.find_or_create_by!(email: "user2@test.org") do |user|
  user.tenant = tenant2
  user.password = "user2@test.org"
  user.password_confirmation = "user2@test.org"
end

fruits_and_vegetables = [
  ["Apple", 1.50, 20],
  ["Banana", 1.20, 25],
  ["Orange", 1.80, 18],
  ["Grapes", 2.50, 15],
  ["Strawberry", 3.20, 12],
  ["Blueberry", 3.50, 10],
  ["Mango", 2.80, 14],
  ["Pineapple", 4.00, 8],
  ["Watermelon", 5.50, 6],
  ["Peach", 2.20, 16],
  ["Pear", 1.90, 13],
  ["Plum", 2.10, 11],
  ["Cherry", 3.00, 9],
  ["Kiwi", 2.40, 12],
  ["Papaya", 3.80, 7],
  ["Carrot", 1.10, 30],
  ["Potato", 1.40, 40],
  ["Tomato", 1.60, 35],
  ["Cucumber", 1.30, 24],
  ["Lettuce", 1.70, 18],
  ["Spinach", 2.10, 15],
  ["Broccoli", 2.30, 12],
  ["Cauliflower", 2.70, 10],
  ["Pepper", 2.00, 20],
  ["Eggplant", 2.40, 14],
  ["Zucchini", 1.80, 16],
  ["Onion", 1.00, 28],
  ["Garlic", 0.90, 22],
  ["Ginger", 1.50, 19],
  ["Pumpkin", 3.20, 8],
  ["Radish", 1.10, 17],
  ["Beet", 1.40, 13],
  ["Turnip", 1.20, 11],
  ["Celery", 1.60, 12],
  ["Asparagus", 2.80, 10],
  ["Green Bean", 2.20, 15],
  ["Peas", 1.90, 16],
  ["Corn", 1.50, 21],
  ["Mushroom", 2.50, 14],
  ["Leek", 1.70, 13],
  ["Artichoke", 3.60, 7],
  ["Cabbage", 1.30, 20],
  ["Kale", 2.10, 12],
  ["Swiss Chard", 2.30, 9],
  ["Parsnip", 1.80, 11],
  ["Rhubarb", 2.00, 10],
  ["Sweet Potato", 1.70, 15],
  ["Yam", 1.60, 13],
  ["Okra", 2.40, 10],
  ["Brussels Sprout", 2.90, 8],
  ["Cilantro", 1.20, 18],
  ["Mint", 1.10, 16],
  ["Basil", 1.50, 14],
  ["Parsley", 1.30, 17],
  ["Dill", 1.40, 12],
  ["Thyme", 1.20, 13],
  ["Rosemary", 1.80, 9],
  ["Sage", 1.70, 10],
  ["Oregano", 1.60, 11],
  ["Lemon", 1.10, 20],
  ["Lime", 1.20, 18],
  ["Avocado", 2.80, 10],
  ["Coconut", 3.20, 8],
  ["Pomegranate", 3.50, 7],
  ["Guava", 2.60, 9],
  ["Passion Fruit", 3.10, 6],
  ["Dragon Fruit", 4.20, 5],
  ["Jackfruit", 4.80, 4],
  ["Lychee", 3.80, 6],
  ["Raspberry", 3.40, 8],
  ["Blackberry", 3.30, 7],
  ["Cantaloupe", 3.60, 6],
  ["Honeydew", 3.20, 5],
  ["Fig", 2.90, 7],
  ["Date", 2.70, 9],
  ["Apricot", 2.80, 8],
  ["Nectarine", 2.50, 10],
  ["Persimmon", 2.60, 7],
  ["Mulberry", 3.00, 6],
  ["Pine Nut", 4.50, 4],
  ["Chestnut", 3.50, 5],
  ["Hazelnut", 3.80, 4]
]

fruits_and_vegetables.each do |name, price, amount|
  Product.find_or_create_by!(tenant: tenant1, name: name) do |product|
    product.price = price
    product.amount = amount
  end

  Product.find_or_create_by!(tenant: tenant2, name: name) do |product|
    product.price = price + 0.25
    product.amount = amount
  end
end

Product.where(tenant: tenant1).where("amount = 0").destroy_all
Product.where(tenant: tenant2).where("amount = 0").destroy_all
