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

      it 'should warn when CPD number increases' do

        allow(@my_plugin.cpd_runner).to receive(:increased?).and_return true
        allow(@my_plugin.cpd_runner).to receive(:installed?).and_return true

        @my_plugin.warn_on_cpd

        expect(@dangerfile.status_report[:warnings]).to eq(["This PR has more duplicated code than your target branch, therefore it could have some code quality issues."])
      end

      it 'should not warn when CPD number stays the same' do

        allow(@my_plugin.cpd_runner).to receive(:increased?).and_return false
        allow(@my_plugin.cpd_runner).to receive(:installed?).and_return true

        @my_plugin.warn_on_cpd

        expect(@dangerfile.status_report[:warnings]).to eq([])
      end

      it 'should warn when PMD is not installed' do

        allow(@my_plugin.cpd_runner).to receive(:installed?).and_return false

        @my_plugin.warn_on_cpd

        expect(@dangerfile.status_report[:warnings]).to eq(["PMD is not currently installed. Copy/Paste Detector can not be executed."])
      end

    end

  end
end
