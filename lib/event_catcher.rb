module EventCatcher

  EVENTS_DIR = (defined?(RAILS_ROOT) ? "#{RAILS_ROOT}/app/events" : "app/events")

  def self.included(base)
    class_eval("@@reporter_events = Array.new")
    base.class_eval("around_filter :events_around_filter")
  end
  
  protected
  
  def events_around_filter
    
    load_events if @@reporter_events.empty?
    events = @@reporter_events.select {|e| e.match_event?(self.class, action_name)}

    # Calling all before actions for this controler and action
    events.each { |event| event.call_before(self) }

    # Calling original action
    yield
    
    # Calling all after actions for this controler and action
    events.each { |event| event.call_after(self) }
  end

  def catch_event(options, &block)
    options.each_pair do |controller, actions|
      if actions.is_a?(Array)
        actions.each {|a| @@reporter_events << EventMeta.new(controller, a, &block) }
      else
        @@reporter_events << EventMeta.new(controller, actions, &block)
      end
    end
  end
  
  def load_events
    return if test?
    Dir["#{EVENTS_DIR}/**/*event.rb"].collect do |file|
      load_event(file)
    end
  end
  
  def load_event(file)
    clear_events if test?
    code = File.new(file).readlines.join('')
    begin
      instance_eval code, __FILE__, __LINE__
    rescue => e
      logger.warn "FAILED!"
      logger.warn e
      logger.warn e.backtrace
    end
  end
  
  def clear_events
    @@reporter_events.clear
  end
  
  def reporter_events
    @@reporter_events
  end
  
  def test?
    Rails.env.test?
  end
    
  class EventMeta
    def initialize(controller_class, name, &block)
      @controller_class = controller_class
      @action = name
      self.instance_eval(&block)
    end

    def call_before(controller_instance)
      controller_instance.instance_eval(&@before) if @before
    end
    
    def call_after(controller_instance)
      controller_instance.instance_eval(&@after) if @after
    end

    def match_event?(clazz, action_name)
      @controller_class == clazz && @action.to_s == action_name.to_s
    end
    private
    
    def before_action(&block)
      @before = block
    end

    def after_action(&block)
      @after = block
    end

  end

end
