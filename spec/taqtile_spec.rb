require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerTaqtile do
    it 'should be a plugin' do
      expect(Danger::DangerTaqtile.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.taqtile
      end

      describe 'Run' do

        it 'should call each validation once' do

          allow(@my_plugin).to receive(:warn_on_cpd).and_return true

          expect(@my_plugin).to receive(:warn_on_cpd).once
          @my_plugin.run

        end

      end

      describe 'CPD' do


        it 'should warn when CPD number increases' do

          allow(@my_plugin.cpd_runner).to receive(:increased?).and_return true
          allow(@my_plugin.cpd_runner).to receive(:installed?).and_return true

          @my_plugin.send(:warn_on_cpd)

          expect(@dangerfile.status_report[:warnings]).to eq(["This PR has more duplicated code than your target branch, therefore it could have some code quality issues."])
        end

        it 'should not warn when CPD number stays the same' do

          allow(@my_plugin.cpd_runner).to receive(:increased?).and_return false
          allow(@my_plugin.cpd_runner).to receive(:installed?).and_return true

          @my_plugin.send(:warn_on_cpd)

          expect(@dangerfile.status_report[:warnings]).to eq([])
        end

        it 'should warn when PMD is not installed' do

          allow(@my_plugin.cpd_runner).to receive(:installed?).and_return false

          @my_plugin.send(:warn_on_cpd)

          expect(@dangerfile.status_report[:warnings]).to eq(["PMD is not currently installed. Copy/Paste Detector can not be executed."])
        end

        # # Study how to handle backtick exceptions
        # # http://blog.bigbinary.com/2012/10/18/backtick-system-exec-in-ruby.html
        # it 'should warn when exception happens' do
        #
        #   error = 'Mocke error message'
        #
        #   allow(@my_plugin.cpd_runner).to receive(:increased?).and_raise error
        #   allow(@my_plugin.cpd_runner).to receive(:installed?).and_return true
        #
        #   @my_plugin.send(:warn_on_cpd)
        #
        #   expect(@dangerfile.status_report[:warnings]).to eq(["Error while executing Copy/Paste Detector: #{error}"])
        # end

      end

    end

  end
end
