class Sport < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :leagues
  has_many :players, -> { order(last_name: :asc, first_name: :asc) }

  def position_options
    position_options =
      name == 'Baseball' ? positions.reject { |pos| %w(LF CF RF).include? pos } : positions
    position_options.unshift 'ALL'
  end

  def self.seed
    supported_sports.each do |sport|
      sport_record = Sport.find_by(name: sport[:name])
      unless sport_record
        sport_record = Sport.new
        sport_record.name = sport[:name]
        sport_record.positions = sport[:positions]
        sport_record.save validate: false
      end
    end
  end

  def self.supported_sports
    [
      { name: 'Baseball', positions: %w(C 1B 2B 3B SS LF CF RF OF SP RP DH) },
      { name: 'Football', positions: %w(QB RB WR TE K DST) }
    ]
  end
end
