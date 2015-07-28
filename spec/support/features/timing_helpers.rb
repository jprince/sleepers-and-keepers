module Features
  module TimingHelpers
    def wait_for_page_ready(time = 0.25)
      sleep time
      yield
    end
  end
end
