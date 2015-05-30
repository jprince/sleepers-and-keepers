class CBSSportsAPI
  include HTTParty
  base_uri 'api.cbssports.com/fantasy'

  def initialize(sport)
    @options = { query: { response_format: 'json', SPORT: sport.downcase, version: '3.0' } }
  end

  def players
    self.class.get('/players/list', @options)
  end
end
