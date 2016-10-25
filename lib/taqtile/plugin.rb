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

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
    def warn_on_cpd
      warn 'This PR has more duplicated code than your target branch, therefore it could have some code quality issues' if @cpd_runner.increased?
    end

    def all
      warn_on_cpd
    end

  end
end
