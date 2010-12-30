require 'cant/engine'
module Cant
  module Embeddable
    # class instance variable can be helpful there
    # 
    # http://rubyquiz.com/quiz67.html
    # http://rubykoans.com/
    #
    # and there is code available, though I did not fully parsed it with enlightenment yet :)
    # https://github.com/ahoward/fattr
    # 
    # see also
    # http://www.ruby-forum.com/topic/197051
    # http://railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/
    # 
    class << self
      def included(base)
        base.extend Cant::Editable
        base.strategy do |rules, receiver, *args|
          Strategies.first_rule_that_predicates_in_receiver(rules, receiver, *args)
        end
        base.die {raise AccessDenied}
        
        # XXX this sucks if class defines its own inherited callback and includes Cant::Embeddable
        # double evil : order of inherited and extend statement has an effect : latter overwrite earlier !!!
        class << base
          def inherited(subclass)
            subclass.rules.concat(rules)
            [:strategy, :die].each do |attr|
              subclass.send(attr, &(send(attr)))
            end
            super
          end
        end
      end
    end
    
    include Cant::Questionable
    def cantfiguration
      self.class
    end    
  end  
end
