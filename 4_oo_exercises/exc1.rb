class SecretFile
  #attr_reader :data

  def initialize(secret_data)
    @data = secret_data
    @security_log = []
  end
  
  def data
    @security_log << SecurityLogger.new.create_log_entry
    
    @data
  end
end

class SecurityLogger
  def create_log_entry
    # ... implementation omitted ...
  end
end