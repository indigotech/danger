module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  taqtile/danger-taqtile
  # @tags pmd, cpd
  #
  class DangerTaqtile < Plugin

    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [CPDRunner]
    attr_accessor :cpd_runner


    def initialize params = {}
      @cpd_runner = Tools::CPDRunner.new
      super
    end

    def run params = {}
      actions = [:warn_on_cpd]
      # remove items from actions based on 'exclude'
      # intersection based on 'only'

      actions.map do |action|
        send(action)
        return action
      end
    end

    private

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
    def warn_on_cpd

      if @cpd_runner.installed?
        warn 'This PR has more duplicated code than your target branch, therefore it could have some code quality issues.' if @cpd_runner.increased?
      else
        warn 'PMD is not currently installed. Copy/Paste Detector can not be executed.'
      end

    end

  end
end
