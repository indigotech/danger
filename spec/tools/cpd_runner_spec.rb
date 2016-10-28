require File.expand_path('../../spec_helper', __FILE__)

module Danger

  module Tools
    describe Danger::Tools::CPDRunner do

      it 'should create runner with default values' do
        runner = CPDRunner.new

        expect(runner.language).to eq('java')
        expect(runner.minimum_tokens).to eq(100)
        expect(runner.folder).to eq(nil)
        expect(runner.repository).to eq(nil)
        expect(runner.branch).to eq('master')

      end

      describe 'Runner' do

        it 'should execute clone and pmd commands' do

          runner = CPDRunner.new

          allow(runner).to receive(:clone_target_banch).and_return(true)
          allow(runner).to receive(:run_cpd_on_current_branch).and_return(300)
          allow(runner).to receive(:run_cpd_on_target_branch).and_return(250)

          expect(runner).to receive(:clone_target_banch).once
          expect(runner).to receive(:run_cpd_on_current_branch).once
          expect(runner).to receive(:run_cpd_on_target_branch).once
          expect(runner.increased?).to eq(true)

        end

        it 'should return false if cpd value did not increase' do

          runner = CPDRunner.new

          allow(runner).to receive(:clone_target_banch).and_return(true)
          allow(runner).to receive(:run_cpd_on_current_branch).and_return(250)
          allow(runner).to receive(:run_cpd_on_target_branch).and_return(250)

          expect(runner.increased?).to eq(false)

        end

      end

      describe 'Instalation' do

        it 'should return false for installation when "which pmd" returns path' do

          runner = CPDRunner.new

          # mock check for pmd instalaton
          allow(runner).to receive(:`).with("which pmd").and_return("anything can be returned here")

          # failing on purpose
          expect(runner.installed?).to eq(true)
        end

        it 'should return false for installation when "which pmd" returns empty' do

          runner = CPDRunner.new

          # mock check for pmd instalaton
          allow(runner).to receive(:`).with("which pmd").and_return("")

          # failing on purpose
          expect(runner.installed?).to eq(false)
        end

      end

      describe 'Bash commands' do

        it 'should call pmd cpd on current branch with correct parameters' do

          runner = CPDRunner.new(folder: "App", language: 'ecmascript', minimum_tokens: 500, repository: 'indigotech/danger', branch: 'release-1.0.0')

          # mocks all calls to system and return invalid value
          allow(runner).to receive(:`).and_return("999")
          # mocks correct call to system
          allow(runner).to receive(:`).with("pmd cpd --language ecmascript --minimum-tokens 500 --files App --ignore-identifiers | grep tokens | wc -l").and_return("10")

          expect(runner.run_cpd_on_current_branch).to eq(10)

        end

        it 'should call pmd cpd on target branch with correct parameters' do

          runner = CPDRunner.new(folder: "App", language: 'ecmascript', minimum_tokens: 500, repository: 'indigotech/danger', branch: 'release-1.0.0')

          # mocks all calls to system and return invalid value
          allow(runner).to receive(:`).and_return("999")
          # mocks correct call to system
          allow(runner).to receive(:`).with("pmd cpd --language ecmascript --minimum-tokens 500 --files target-branch/App --ignore-identifiers | grep tokens | wc -l").and_return("100")

          expect(runner.run_cpd_on_target_branch).to eq(100)

        end

        it 'should clone target branch with correct parameters' do

          runner = CPDRunner.new(folder: "App", language: 'ecmascript', minimum_tokens: 500, repository: 'indigotech/danger', branch: 'release-1.0.0')

          # mocks all calls to system and return invalid value
          allow(runner).to receive(:`).and_return(false)
          # mocks correct call to system
          allow(runner).to receive(:`).with("git clone --depth 1 https://github.com/indigotech/danger.git --branch release-1.0.0 target-branch").and_return(true)

          expect(runner.clone_target_banch).to eq(true)

        end

      end


    end
  end
end
