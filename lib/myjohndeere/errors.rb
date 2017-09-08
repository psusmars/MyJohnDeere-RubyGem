module MyJohnDeere
  # MyJohnDeereError is the base error from which all other more specific MyJohnError
  # errors derive.
  class MyJohnDeereError < StandardError
  end

  # Configuration error is raised when configuration hasn't been properly done
  class ConfigurationError < MyJohnDeereError
  end
end