require File.dirname(__FILE__) + '/lib/event_catcher'

Rails::Initializer.run(:set_load_path) do |config|
  config.load_paths += %W(#{RAILS_ROOT}/app/events) 
end

ApplicationController.send(:include, EventCatcher)
