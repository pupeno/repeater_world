Kaminari.configure do |config|
  config.default_per_page = 60
  config.max_per_page = 60
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  config.param_name = :p
  # config.max_pages = nil
  # config.params_on_first_page = false
end
