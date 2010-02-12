require 'fileutils'

class EventGenerator < Rails::Generator::NamedBase
  def manifest
    create_events_dir
    record do |m|
      m.template "event.rb", "app/events/#{file_name}_event.rb"
    end
  end

  private
  def create_events_dir
    d = "#{RAILS_ROOT}/app/events"
    FileUtils.mkdir(d) unless File.exist?(d)
  end
end