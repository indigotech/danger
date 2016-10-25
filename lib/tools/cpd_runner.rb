module Danger

  module Tools

    # Runs PMD's Copy-Paste Detector at current source and compare it to
    # other branches value. More info at
    # http://pmd.sourceforge.net/pmd-4.3.0/cpd.html
    #
    # @example Compare current code with code on branch 'master'
    #
    #          cpd = CPDRunner.new branch: 'master'
    #          cpd.compare()
    #
    class CPDRunner

      # Language being used for comparison. Defaults to java.
      #  Other possible values are cpp, cs java, php, ruby, and ecmascript
      #
      # @return   [String]
      attr_accessor :language


      # A positive integer indicating the minimum duplicate size.
      #
      # @return   [Integer]
      attr_accessor :minimum_tokens


      # Folder where files to be compared are located
      #
      # @return   [String]
      attr_accessor :folder

      # Repository slug. Example, for https://github.com/fastlane/fastlane.git,
      #  repo slug is fastlane/fastlane
      #
      # @return   [String]
      attr_accessor :repository

      # Remote branch to compare current code with
      #
      # @return   [String]
      attr_accessor :branch

      def initialize params = {}
        params.each { |key, value| send "#{key}=", value }

        # some default values
        @language = params[:language] || 'java'
        @minimum_tokens = params[:minimum_tokens] || 100
        @branch = params[:branch] || "master"
        @repository = params[:repository] || ENV['TRAVIS_REPO_SLUG'] || nil
        @super
      end

      def increased?
        clone_target_banch
        current_branch_cpd_results = run_cpd_on_current_branch
        target_branch_cpd_results = run_cpd_on_target_branch
        return current_branch_cpd_results > target_branch_cpd_results
      end

      def run_cpd_on_current_branch
        `pmd cpd --language #{@language} --minimum-tokens #{@minimum_tokens} --files #{@folder} --ignore-identifiers | grep tokens | wc -l`.to_i
      end

      def clone_target_banch
        `git clone --depth 1 https://github.com/#{@repository}.git --branch #{@branch} target-branch`
      end

      def run_cpd_on_target_branch
        `pmd cpd --language #{@language} --minimum-tokens #{@minimum_tokens} --files target-branch/#{@folder} --ignore-identifiers | grep tokens | wc -l`.to_i
      end

    end

  end

end
