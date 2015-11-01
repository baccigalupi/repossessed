class User < ActiveRecord::Base
end

class Greeter < ActiveRecord::Base
end

class ProgramConfiguration < ActiveRecord::Base
  self.inheritance_column = :_type_disabled
end
