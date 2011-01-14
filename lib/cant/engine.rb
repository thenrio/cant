module Cant
  module Editable
    # list of Rules
    # returns the list of rules for this device
    def rules
      unless @rules
        @rules = []
        @rules.concat(Cant.rules) unless self == Cant
      end
      @rules
    end    
    # add a Rule, as a pair of functions {predicate, die}
    #
    # block form sets predicate function.
    # block can have argument, (as any proc)
    #
    # eg :
    #  rooms = [:kitchen] 
    #  cant {|context| rooms.include?(context[:room]) and context[:user]}
    #  cant {current_user.admin?}
    #
    # returns a rule which die function can be configured
    #
    #   cant do |controller|
    #     controller.request.path =~ /admin/ unless controller.current_user.admin?
    #   end.die do |controller| 
    #     raise AccessDenied.new(controller.request)
    #   end
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

    # set default die function for this device
    #
    # example : 
    #   die do |request|
    #     raise AccessDenied, "Cant process #{request}"
    #   end
    def die(&block)
      @die = block unless block.nil?
      @die || Cant.die
    end
    
    # define fold function
    # fold function has arity 2..n
    # - rules : the rules to traverse
    # - receiver : a Questionable asking for cant?
    # - *args : the arguments for each rule to pass to predicate functions
    # 
    # returns a rule if strategy evaluates it cant do
    # nil either
    #
    # eg :
    #   fold {true} #=> always cant
    #   fold {|rules, _receiver, context| rules.reverse.find {|rule| rule.predicate?(context)}}
    def fold(&block)
      @fold = block unless block.nil?
      @fold || Cant.fold
    end
  end
  
  # module level configuration
  #   Cant.fold
  #   Cant.die
  class << self
    include Editable
  end
  # module level default values
  fold {|rules, receiver, *args| Folds.first_rule_that_predicates_in_receiver(rules, receiver, *args)}
  die {|*args| raise AccessDenied, "Cant you do that #{args}, can you ??"}
  
  # questionable interface
  module Questionable
    # Public : verify whether you cant
    #
    # *args - list of params to pass to rules
    #
    # Returns : a rule that cant, according rules folding, or nil
    def cant?(*args)
      cantfiguration.fold.call(cantfiguration.rules, self, *args)
    end
    # Public : run die code if you cant
    #
    # *args - list of params to pass to rules and die function
    #
    # Returns : die result or nil if it can
    def die_if_cant!(*args)
      rule = cant?(*args)
      rule.die!(*args) if rule
    end
    
    attr_writer :cantfiguration
    protected
    def cantfiguration
      @cantfiguration ||= Object.new.extend(Editable)
    end
  end

  # standalone engine
  class Engine
    include Editable
    include Questionable
    def cantfiguration
      self
    end
  end

  # a Rule is a pair of functions :
  # - predicate(*args), that return true if predicate is met (hint of predicate?)
  # - die(*args), that cant raise if convenient
  #
  # this class could have been:
  # - spared
  # - an Array, with an optional syntactic sugar
  # - a property list in erlang
  class Rule
    # a new rule with a predicate and response function
    def initialize(predicate=nil, die=Cant.die)
      @predicate=predicate
      @die = die
    end
    # set or return predicate function using block
    # 
    # return true means rule can die
    #
    # example : 
    #   predicate do |request|
    #     not current_user.admin? if request.path =~ /^\/admin/ 
    #   end    
    def predicate(&block)
      @predicate = block unless block.nil?
      @predicate
    end
    # evaluates predicate function with args
    def predicate?(*args)
      predicate.call(*args)
    end    
    # set die function using block
    #
    # example : 
    #   die do |request|
    #     raise AccessDenied, "Cant process #{request}"
    #   end
    def die(&block)
      @die = block unless block.nil?
      @die
    end
    # call die function with args
    # 
    # *args - variable list of arguments
    def die!(*args)
      die.call(*args)
    end
  end
  
  module Folds
    class << self
      # first rule that predicates to true, all args are carried to closure
      # this strategy does not use the receiver argument, and evaluate each predicate with the binding of its creation
      def first_rule_that_predicates(rules, _receiver, *args)
        rules.find {|rule| rule.predicate?(*args)}
      end
      # strategy that evals block in receiver context
      # closure is rebound to receiver (acting as a function)
      def first_rule_that_predicates_in_receiver(rules, receiver, *args)
        rules.find do |rule|
          receiver.instance_exec(*args, &(rule.predicate))
        end
      end
    end
  end
    
  class AccessDenied < RuntimeError; end
end
