require 'spec_helper'

describe ConfigSanitizer do
  class DummyClass
  end

  @attributes = %w(name? username? gender? birthdate?)
#  p "attributes = #{@attributes}"

  before(:all) do
#  	p "In Before all"
    @dummy = DummyClass.new
    @dummy.extend ConfigSanitizer
  end

  describe "check_config" do
  	let(:config) { FactoryGirl.build(:full_config) }
    it "passes check" do
    	expect(@dummy.check_config(config)).to eq(true)
    end
  end

#  p "attributes before loop = #{@attributes}"

  @attributes.each do |attr|
  	describe "check_config of attribute: #{attr}" do
#  		let(:config) { @CONFIG.deep_dup }
      let(:config) { FactoryGirl.build(:full_config) }
  		let(:require_sym) { "require_#{attr}".to_sym }
  		let(:enable_sym)  { "enable_#{attr}".to_sym  }
#  		let(:config) { FactoryGirl.build(:config, reqire_sym => true, enable_sym => false) }
  		before do
  			config[require_sym] = true
  			config[enable_sym] = false
  		end

  		it "fails check" do
 # 			p "In it fails check. Attr = #{attr}, config = #{config}"
  			expect {
  				@dummy.check_config(config)
  				}.to raise_error ConfigSanitizer::ConfigError
  		end
  	end #describe

  end #loop
end
