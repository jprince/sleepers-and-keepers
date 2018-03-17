class Player < ActiveRecord::Base
  acts_as_paranoid

  require 'logger'

  validates :last_name, presence: true
  validates :orig_id, presence: true
  validates :position, presence: true
  validates :team, presence: true
  belongs_to :sport
  has_many :picks
  has_many :teams, through: :picks

  def name
    first_name.blank? ? last_name : "#{last_name}, #{first_name}"
  end

  def self.undrafted(league)
    players = league.sport.players.to_a
    drafted_player_ids = league.picks.where.not(player_id: nil).pluck(:player_id)
    players.reject! { |player| drafted_player_ids.include? player.id } || players
  end

  def self.update_player_pool
    logger = Logger.new(STDOUT)

    Sport.supported_sports.each do |sport|
      sport = Sport.find_by(name: sport[:name])

      if sport
        api = CBSSportsAPI.new(sport.name)
        data = ActiveSupport::JSON.decode(api.players)['body']['players']
        filtered_players = data.select { |player| sport.positions.include? player['position'] }

        filtered_players.each do |player|
          player_orig_id = player['id']
          player_record = Player.with_deleted.find_by(orig_id: player_orig_id)

          if player_record
            if player_record.deleted?
              logger.info "Restored #{player_record.name}"
              player_record.restore
            end
            logger.info "Updated #{player_record.name}"
            set_player_attributes(player_record, player)
          else
            logger.info "Added #{player['lastname']}, #{player['firstname']}"
            player_record = Player.new
            set_player_attributes(player_record, player)
            player_record.orig_id = player_orig_id
            player_record.sport_id = sport.id
          end
          player_record.save!
        end

        sport.players.each do |player|
          unless filtered_players.map { |p| p['id'] }.include? player.orig_id
            logger.info "Removed #{player.last_name}, #{player.first_name}"
            player.destroy
          end
        end
      end
    end
  end

  def self.outfield_positions
    %w[CF LF OF RF]
  end
  private_class_method :outfield_positions

  def self.set_player_attributes(player_record, player)
    player_record.first_name = player['firstname']
    player_record.headline = player.try(:[], 'icons').try(:[], 'headline')
    player_record.injury = player.try(:[], 'icons').try(:[], 'injury')
    player_record.last_name = player['lastname']
    player_record.photo_url = player['photo']
    player_record.position =
      outfield_positions.include?(player['position']) ? 'OF' : player['position']
    player_record.pro_status = player['pro_status']
    player_record.team = player['pro_team']
    player_record
  end
  private_class_method :set_player_attributes
end
