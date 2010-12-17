module Cant
  class << self
    attr_writer :rules
    def rules
      @rules ||= []
    end
  end 

  class Engine
    def initialize(options={})
      self.rules.concat(Cant.rules)
      @raising = ({:raising => true}.merge(options))[:raising]
      @strategy = lambda {|rules, *args| Strategies.true_if_any_true(rules, *args)}
    end

    # evaluates instance rules with instance strategy
    # return true if strategy is true
    # else false or raise Cant::Unauthorized if raising?
    def can?(context={})
      return true if @strategy.call(rules, context)
      raise Cant::Unauthorized.new(%{can't you do that?\n#{context}}) if raising?
      false
    end

    # add a rule that when context is met, then response is what block evaluates to
    # block can have up one argument
    # - the context of invocation
    # eg :
    #  rooms = [:kitchen] 
    #  can {|context| rooms.include?(context[:room]) and context[:user]}
    #  can {current_user.admin?}
    def can(&block)
      rules << block
    end

    def rules
      @rules ||= []
    end

    def raising(raising)
      @raising = raising
      self
    end
    
    # will can? raise when strategy is evaled to false ?
    def raising?
      @raising
    end
    
    # use a new strategy for can?
    # a strategy is a function of arity 1..n
    # - the rules to traverse
    # - the arguments for each rule (a optionnal context)
    # eg :
    # strategy {false} #=> always cant
    # strategy {|rules, context| rules.all? {|rule| rule.call(context)}}
    def strategy(&block)
      @strategy = block
    end
  end
  
  module Strategies
    class << self
      # default strategy : true if any rule evaluate to true in context
      def true_if_any_true(rules, *args)
        rules.any? {|rule| 
          rule.respond_to?(:call) ? rule.call(*args) : rule
        }
      end
    end
  end
  
  class Unauthorized < RuntimeError; end
end
