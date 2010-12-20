module Cant
  module Editable
    # current rules
    def rules
      unless @rules
        @rules = []
        @rules.concat(Cant.rules) unless self == Cant
      end
      @rules
    end    
    # add a rule, as a pair of functions (predicate, response)
    #
    # block form sets predicate function
    # block can have argument, as a proc
    #
    # eg :
    #  rooms = [:kitchen] 
    #  cant {|context| rooms.include?(context[:room]) and context[:user]}
    #  cant {current_user.admin?}
    #
    # returns a rule which response which response can be configured
    #
    # cant do |controller|
    #   controller.request.path =~ /admin/ unless controller.current_user.admin?
    # end.respond do |controller| 
    #   raise AccessDenied.new(controller.request)
    # end
    # 
    # options form looks for the predicate and response functions as values in options, 
    # under symbols :predicate and :response
    # 
    # cant :predicate => proc {|controller| not controller.current_user}, 
    #   :response => proc {|controller| controller.redirect '/users/sign_in'}
    def cant(options={}, &block)
      rule = if block.nil?
        Rule.new(options[:predicate], options[:response] || self.response)
      else
        Rule.new(block, self.response)
      end
      rules << rule
      rule
    end

    # use response function that defaults to Cant.response if a block is given
    # return response function or module default response function
    def response(&block)
      @response = block unless block.nil?
      @response || Cant.response
    end
    
    # use a new strategy for cant?
    # a strategy is a fold function of arity 1..n
    # - the rules to traverse
    # - the arguments for each rule (an optionnal context) to pass to predicate function
    # 
    # returns a rule if strategy evaluates it cant do
    # nil | false either
    #
    # eg :
    # strategy {true} #=> always cant
    # strategy {|rules, context| rules.reverse.find {|rule| rule.predicate?(context)}}
    def strategy(&block)
      @strategy = block unless block.nil?
      @strategy || Cant.strategy
    end
  end
  
  # module level configuration
  # Cant.cant
  # Cant.strategy
  # Cant.respond
  class << self
    include Editable
  end
  # module level default values
  strategy {|rules, *args| Strategies.first_rule_that_predicates(rules, *args)}
  response {true}
  
  # questionable interface
  module Questionable
    def configuration
      @configuration ||= Object.new.extend(Editable)
    end
    # return what strategy evaluates rules given context
    def cant?(context=nil)
      configuration.strategy.call(configuration.rules, context)
    end
    
    # return response function of strategy evaluation
    def cant!(context=nil)
      rule = cant?(context)
      rule.respond!(context) if rule
    end
  end

  # full engine
  class Engine
    include Editable
    include Questionable
    def configuration
      self
    end
  end

  # a Rule is a pair of functions :
  # - predicate(*args), that return true if predicate is met (hint of predicate?)
  # - response(*args), that returns true or raise if convenient
  # this class could have been:
  # -spared
  # -an Array, with a optional syntactic sugar
  class Rule
    # a new rule with a predicate and response function
    def initialize(predicate=nil, response=Cant.response)
      @predicate=predicate
      @response = response
    end
    attr_reader :predicate, :response
    # set response function using block
    def respond(&block)
      @response = block
      self
    end
    # call response function with args
    def respond!(*args)
      response.call(*args)
    end
    # evaluates predicate function with args
    def predicate?(*args)
      predicate.call(*args)
    end
  end
  
  module Strategies
    class << self
      # default strategy : first rule that predicates to true
      def first_rule_that_predicates(rules, *args)
        rules.find {|rule| rule.predicate?(*args)}
      end
    end
  end
  
  class Unauthorized < RuntimeError; end
end
