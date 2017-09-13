module MyJohnDeere
  class ListObject < Requestable
    OPTION_ATTRIBUTES = [:count, :start, :etag]
    attr_reader :data, :listable, :total, :options
    include Enumerable

    OPTION_ATTRIBUTES.each do |attribute|
      define_method("#{attribute}=") do |val|
        options[attribute] = val
      end
      define_method(attribute) do
        return options[attribute]
      end    
    end

    def initialize(listable, access_token, json_data,
      options: {})
      @options = options
      # Confirm object is listable? 
      @listable = listable
      @data = json_data["values"].collect { |i| listable.new(i, access_token) }
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

    def using_etag?
      # will be equal "" or some other string
      return !self.etag.nil?
    end
  end
end
  # def iterate_through_john_deere_resource(john_deere_resource_path, options={})
  #   options = {
  #     headers: nil,
  #     body: ""
  #     }.merge(options)
  #   loop do
  #     response = self.request_against_access_token(:get, john_deere_resource_path, options)

  #     case response.code.to_s
  #     when "304" # Not modified, the headers won't change either
  #       logger.info("JohnDeere iteration not modified: #{john_deere_resource_path}")
  #       break
  #     when "200" # Success
  #       # now make the json and yield it to the block
  #       response_json = JSON.parse(response.body)

  #       yield(response_json, response.to_hash)

  #       # see if we have another page, will either be nil or the hash, which will have ["uri"]
  #       next_uri = response_json["links"].find { |link| link["rel"] == "nextPage" }
  #       full_resource_uri = next_uri.try(:[], "uri")
  #       break if full_resource_uri.nil?

  #       # convert it to a regular path so we don't have to mess with the 
  #       # full route
  #       john_deere_resource_path = URI.parse(full_resource_uri).path

  #       # one final check
  #       break if john_deere_resource_path.nil?
  #     else
  #       break
  #     end
  #   end
  # end