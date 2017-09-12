module MyJohnDeere
  class ListObject < Requestable
    attr_accessor :count, :start
    attr_reader :data, :listable, :etag, :total
    include Enumerable

    def initialize(listable, access_token, data, 
      start:0, count: 10, etag: nil, total: nil)
      # Confirm object is listable? 
      @listable = listable
      @data = data
      @start = start
      @count = count
      @etag = etag
      # Total is the total record count as specified by the john deere response
      @total = total || data.length
      super(access_token)
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
      return self.start + self.data.length < self.total
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