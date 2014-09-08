Rails.application.config.generators do |g|
  g.helper false
  g.assets false
  g.view_specs false
  g.test_framework :mini_test, spec: true
end