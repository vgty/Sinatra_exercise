require 'sinatra'
require 'json'

set :bind, '127.0.0.1'
set :port, 5000
set :views, settings.root + '/html'

require 'data_mapper'

DataMapper.setup(:default, 'sqlite:spriggly-wiggly.db')

class Restaurant
  include DataMapper::Resource

  property :id, Serial
  property :location, Text, required: true
  property :name, Text, required: true 

  has n, :orders, :constraint => :destroy  
end

class Order
  include DataMapper::Resource

  property :id, Serial
  property :description, Text, required: true
  property :restaurant_id, Integer, required: true

  belongs_to :restaurant
end

DataMapper.finalize()
DataMapper.auto_upgrade!()

# application root
get('/') do
  restaurants = Restaurant.all
  erb(:index, locals: { restaurants: restaurants })
end
# render a create restaurant form
get('/restaurants/create') do
  erb(:create_restaurant)
end
post('/restaurants') do
  new_restaurant = Restaurant.new
  new_restaurant.name = params[:name]
  new_restaurant.location = params[:location]
  new_restaurant.save
  redirect('/')
end

get('/restaurants/:id/edit') do
  restaurant = Restaurant.get(params[:id])
  erb(:edit_restaurant, locals: { restaurant: restaurant })
end

put('/restaurants/:id') do
  restaurant = Restaurant.get(params[:id])
  restaurant.name = params[:name]
  restaurant.location = params[:location]
  restaurant.save
  redirect('/')
end

delete('/restaurants/:id') do
  Restaurant.get(params[:id]).destroy
  redirect('/')
end

post('/orders') do
  new_order = Order.new
  new_order.description = params[:description]
  new_order.restaurant_id = params[:restaurant_id]
  new_order.save
  redirect('/')
end

get('/orders/:id/edit') do
  order = Order.get(params[:id])
  erb(:edit_order, locals: { order: order })
end

put('/orders/:id') do
  order = Order.get(params[:id])
  order.description = params[:description]
  order.save
  redirect('/')
end

# delete order
delete('/orders') do
  order_to_delete = Order.get(params[:order_id])
  order_to_delete.destroy
  redirect('/')
end

get('/api/restaurants') do
  restaurants = Restaurant.all
  json_response = { restaurants: restaurants }.to_json
  return(json_response)
end
get('/api/restaurants/:id/orders') do
  restaurant = Restaurant.get(params[:id])
  json_response = { orders: restaurant.orders }.to_json
  return(json_response)
end