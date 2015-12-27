require 'benchmark'
require 'logger'
require 'json'

namespace :benchmark do
  task :sample do
    data = render_file * 10_000
    times = 100
    Logger.new(STDOUT).info "timing #{data.length} rows #{times} times"

    Benchmark.bm do |bm|
      bm.report 'each' do
        times.times do
          data.each do |row|
            if !@first_row_written
              row.keys
              @first_row_written = true
            else
              row.values
            end
          end
        end
      end

      bm.report 'each_with_index' do
        times.times do
          data.each_with_index do |row, index|
            index.zero? ? row.keys : row.values
          end
        end
      end
    end
  end

  def self.render_file
    [{ 'col1' => 'value', 'col2' => 1, 'col3' => true }]
  end
end
