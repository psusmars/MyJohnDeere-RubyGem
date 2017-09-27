module MyJohnDeere
  class ListObject < Requestable
    OPTION_ATTRIBUTES = [:count, :start, :etag]
    attr_reader :data, :listable, :total, :options, :last_response_code
    include Enumerable

    OPTION_ATTRIBUTES.each do |attribute|
      define_method("#{attribute}=") do |val|
        options[attribute] = val
      end
      define_method(attribute) do
        return options[attribute]
      end    
    end

    def initialize(listable, access_token, json_data, last_response_code,
      options: {})
      @last_response_code = last_response_code
      @options = options
      # Confirm object is listable? 
      @listable = listable
      json_data = {} if not_modified?
      @data = (json_data["values"] || []).collect { |i| listable.new(i, access_token) }
      if self.using_etag?
        MyJohnDeere.logger.info("Using etag, ignoring any specification about start/count")
        self.start = 0
        self.count = @data.length
      else
        MyJohnDeere.logger.info("Etag omitted using start/count")
        self.start ||= 0
        self.count ||= 10
      end
      # Total is the total record count as specified by the john deere response
      @total = json_data["total"] || data.length
      super(json_data, access_token)
    end

    def each(&blk)
      self.data.each(&blk)
    end

    def next_page!()
      return if !self.has_more?()
      new_list = @listable.list(self.access_token, 
        count: self.count, 
        start: self.start + self.count,
        etag: self.etag)
      new_list.instance_variables.each do |iv|
        self.instance_variable_set(iv, new_list.instance_variable_get(iv))
      end
    end

    def has_more?()
      return !self.using_etag? && self.start + self.data.length < self.total
    end

    def not_modified?
      return self.last_response_code == 304
    end

    def using_etag?
      # will be equal "" or some other string
      return !self.etag.nil?
    end
  end
end