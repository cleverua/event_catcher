catch_event <%= class_name %>Controller => :index do

  before_action do
    puts 'This block is exectued BEFORE the action'
  end

  after_action do
    puts 'This block is exectued AFTER the action'
  end

end