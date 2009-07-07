# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
 
# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

module BeforeAndAfter

  LEFT_SIDE_LATER  = 1
  RIGHT_SIDE_LATER = -1
  
  def before?(input_time)
    (self <=> input_time) == RIGHT_SIDE_LATER
  end
  
  def after?(input_time)
    (self <=> input_time) == LEFT_SIDE_LATER
  end
end

Time.send :include , BeforeAndAfter

module Spec
  module Mocks
    module ArgumentMatchers
      class DateAroundMatcher

        # Takes an argument of expected date
        def initialize(expected)
          @expected = expected
        end

        # actual is a date (hopefully) passed to the method by the user.
        # We'll check if this date is 'around' expected date, where 'around' means
        # thay don't differ more than a second
        def ==(actual)
          if actual.kind_of? Time
             return (actual - @expected).abs < 1.second
          else
            return false
          end
        end

        def description
          "date around #{@expected}"
        end

      end

      # Usage:
      #  some_mock.should_receive(:message).with( date_around(Time.now) )
      def date_around(*args)
        DateAroundMatcher.new(*args)
      end
    end
  end
end

module DisableFlashSweeping
  def sweep
  end
end
