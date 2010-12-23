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
    # options form looks for the predicate and die functions as values in options, 
    # under symbols :predicate and :die
    # 
    # cant :predicate => proc {|controller| not controller.current_user}, 
    #   :die => proc {|controller| controller.redirect '/users/sign_in'}
    def cant(options={}, &block)
      rule = if block.nil?
        Rule.new(options[:predicate], options[:die] || self.die)
      else
        Rule.new(block, self.die)
      end
      rules << rule
      rule
    end

    # block form : use provided block as die function
    # return die function or Cant.die module function
    def die(&block)
      @die = block unless block.nil?
      @die || Cant.die
    end
    
    # use a new strategy for rules folding
    # a strategy is a fold function of arity 1..n
    # - the rules to traverse
    # - a receiver
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
  # Cant.die
  class << self
    include Editable
  end
  # module level default values
  strategy {|rules, receiver, *args| Strategies.first_rule_that_predicates(rules, receiver, *args)}
  die {true}
  
  # questionable interface
  module Questionable
    def configuration
      @configuration ||= Object.new.extend(Editable)
    end
    # return strategy fold for rules with context (a rule or nil)
    def cant?(*args)
      configuration.strategy.call(configuration.rules, self, *args)
    end
    # return evaled die function of strategy fold
    def cant!(*args)
      rule = cant?(*args)
      rule.die!(*args) if rule
    end
  end

  # standalone engine
  class Engine
    include Editable
    include Questionable
    def configuration
      self
    end
  end

  # a Rule is a pair of functions :
  # - predicate(*args), that return true if predicate is met (hint of predicate?)
  # - die(*args), that cant raise if convenient
  # this class could have been:
  # -spared
  # -an Array, with a optional syntactic sugar
  class Rule
    # a new rule with a predicate and response function
    def initialize(predicate=nil, die=Cant.die)
      @predicate=predicate
      @die = die
    end
    # set or return predicate function using block
    def predicate(&block)
      @predicate = block unless block.nil?
      @predicate
    end
    # evaluates predicate function with args
    def predicate?(*args)
      predicate.call(*args)
    end    
    # set die function using block
    def die(&block)
      @die = block unless block.nil?
      @die
    end
    # call die function with args
    def die!(*args)
      die.call(*args)
    end
  end
  
  module Strategies
    class << self
      # first rule that predicates to true, all args are carried to closure
      # binding of closure might not be related to receiver
      def first_rule_that_predicates(rules, _receiver=nil, *args)
        rules.find {|rule| rule.predicate?(*args)}
      end
      # strategy that evals block with in receiver context
      # that is closure is rebound to receiver (acting like a function)
      def first_rule_that_predicates_in_receiver(rules, receiver, *args)
        rules.find do |rule|
          receiver.instance_exec(*args, &(rule.predicate))
        end
      end
    end
  end
  
  class Unauthorized < RuntimeError; end
end
