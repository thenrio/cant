module Cant
  module Editable
    attr_writer :rules
    # current rules
    def rules
      @rules ||= []
      @rules.concat(Cant.rules) unless self == Cant
      @rules
    end    
    # add a rule that when context is met, then response is what block evaluates to
    #
    # block can have up one argument
    # - the context of invocation
    # eg :
    #  rooms = [:kitchen] 
    #  cant {|context| rooms.include?(context[:room]) and context[:user]}
    #  cant {current_user.admin?}
    #
    # returns a rule which response which response an be configured
    # cant do |controller|
    #   controller.request.path =~ /admin/ unless controller.current_user.admin?
    # end.respond do |controller| 
    #   raise AccessDenied.new(controller.request)
    # end
    def cant(&block)
      rule = Rule.new(block, self.response || Cant.response)
      rules << rule
      rule
    end
    
    # default response function
    def respond(&block)
      @response = block
    end
    def response
      @response || proc {true}
    end
  end
  
  class << self
    include Editable
  end 

  module Engine
    include Editable
    # evaluates instance rules with instance strategy
    # return true if strategy is true
    # else false or raise Cant::Unauthorized if raising?
    def cant?(context={})
      strategy.call(rules, context)
    end
    
    # use a new strategy for cant?
    # a strategy is a function of arity 1..n
    # - the rules to traverse
    # - the arguments for each rule (an optionnal context)
    # eg :
    # strategy {true} #=> always cant
    # strategy {|rules, context| rules.all? {|rule| rule.call(context)}}
    def strategy(&block)
      @strategy = block unless block.nil?
      @strategy ||= lambda {|rules, *args| Strategies.respond_when_first_predicate_is_true(rules, *args)}
    end
  end

  # a Rule is a pair of functions :
  # - predicate(*args), that return true if predicate is met (hint of predicate?)
  # - response(*args), that returns a false or raise
  class Rule
    # a new rule with a predicate function
    def initialize(predicate=nil, response=Cant.response)
      @predicate=predicate
      @response = response
    end
    # set response function using block
    def respond(&block)
      @response = block
      self
    end
    # call response function with args
    def respond!(*args)
      @response.call(*args)
    end
    # evaluates predicate function with args
    def predicate?(*args)
      @predicate.call(*args)
    end
  end
  
  module Strategies
    class << self
      # default strategy : return respond! of first rule that predicates to true, false either
      def respond_when_first_predicate_is_true(rules, *args)
        rule = rules.find {|rule| rule.predicate?(*args)}
        return rule.respond!(*args) if rule
        false
      end
    end
  end
  
  class Unauthorized < RuntimeError; end
end
