task(:coffeelint).clear

task :coffeelint do
  file_pattern = '{app,spec}/**/*.coffee'

  config = {
    arrow_spacing: { level: 'error' },
    max_line_length: {
      level: 'error',
      value: 99
    },
    no_backticks: { level: 'ignore' },
    no_empty_param_list: { level: 'error' },
    prefer_english_operator: { level: 'error' }
  }

  results = Dir.glob(file_pattern).map { |f| Coffeelint.run_test(f, config) }

  unless results.all?
    puts 'Coffeelint failed!'
    abort
  end
end
