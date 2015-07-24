class Player < ActiveRecord::Base
  require 'logger'

  validates :last_name, presence: true
  validates :orig_id, presence: true
  validates :position, presence: true
  validates :team, presence: true
  belongs_to :sport
  has_many :picks
  has_many :teams, through: :picks

  def self.undrafted(league)
    players = league.sport.players
    drafted_players = league.picks.map(&:player)
    players - drafted_players
  end

  def self.update_player_pool
    logger = Logger.new(STDOUT)

    Sport.supported_sports.each do |sport|
      sport = Sport.find_by(name: sport[:name])

      unless sport.nil?
        api = CBSSportsAPI.new(sport.name)
        data = ActiveSupport::JSON.decode(api.players)['body']['players']
        allowed_positions = sport.positions
        filtered_players = data.select { |player| allowed_positions.include? player['position'] }
        filtered_players.each do |player|
          player_orig_id = player['id']
          player_record = Player.find_by(orig_id: player_orig_id)

          if player_record.blank?
            logger.info "Added #{ player['lastname'] }, #{ player['firstname'] }"
            player_record = Player.new
            set_player_attributes(player_record, player)
            player_record.orig_id = player_orig_id
            player_record.sport_id = sport.id
          else
            logger.info "Updated #{ player['lastname'] }, #{ player['firstname'] }"
            set_player_attributes(player_record, player)
          end

          player_record.save
        end
      end
    end
  end

  private

  def self.set_player_attributes(player_record, player)
    player_record.first_name = player['firstname']
    player_record.headline = player.try(:[], 'icons').try(:[], 'headline')
    player_record.injury = player.try(:[], 'icons').try(:[], 'injury')
    player_record.last_name = player['lastname']
    player_record.photo_url = player['photo']
    player_record.position = player['position']
    player_record.pro_status = player['pro_status']
    player_record.team = player['pro_team']
    player_record
  end
end
