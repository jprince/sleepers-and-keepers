DraftStatus.where(description: 'Not Started').first_or_create!
DraftStatus.where(description: 'In Progress').first_or_create!
DraftStatus.where(description: 'Complete').first_or_create!
Sport.seed
user = User.where(email: 'user@example.com')

if user.blank?
  user = user.build
  user.first_name = 'Test'
  user.last_name = 'User'
  user.password = 'asdASD123!@#'
  user.save
end

if Rails.env == 'development'
  league = League.where(name: 'Metrowest Fantasy Football League')
  if league.blank?
    league = league.build
    league.name = 'Metrowest Fantasy Football League'
    league.sport_id = Sport.find_by(name: 'Football').id
    league.password = 'asdASD123!@#'
    league.size = 12
    league.rounds = 15
    league.user_id = User.find_by(email: 'user@example.com').id
    league.draft_status_id = DraftStatus.find_by(description: 'Not Started').id
    league.save

    teams = [
      { name: 'The Iron Fury', short_name: 'Fury' },
      { name: "John's Jaguars", short_name: 'Jaguars' },
      { name: "Billy's Big Ballers", short_name: 'Ballers' },
      { name: 'DDZ', short_name: 'DDZ' },
      { name: 'Fitivity Inc', short_name: 'Fitivity' },
      { name: 'Illegal Procedure', short_name: 'Ill Pro' },
      { name: 'One Time', short_name: 'One Time' },
      { name: 'The Assman', short_name: 'Assman' },
      { name: 'The Fruitcakes', short_name: 'Fruitcakes' },
      { name: 'The Savages', short_name: 'Savages' },
      { name: 'Yellafeva', short_name: 'Feva' },
      { name: 'DJ Manolo', short_name: 'Manolo' }
    ]

    league.size.times do |n|
      user = User.new(
        email: "user-#{n + 1}@example.com",
        first_name: 'User',
        last_name: "#{n + 1}",
        password: 'asdASD123!@#'
      )
      user.save

      team = teams[n]
      team = user.teams.create(
        name: team[:name],
        short_name: team[:short_name],
        draft_pick: n + 1,
        league_id: league.id
      )
      team.save
    end
  end
end
