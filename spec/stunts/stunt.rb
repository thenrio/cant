class Stunt
  def initialize(properties={})
    properties.each { |k,v|
      (class << self; self end).module_eval {
        attr_accessor k
        alias_method "#{k}?".to_sym, k if [TrueClass, FalseClass].include?(v.class)        
      }
      self.send("#{k}=", v)
    }
  end
end