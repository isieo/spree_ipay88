require 'spec_helper'

describe Spree::BillingIntegration::Ipay88 do

  before(:each) do
    @gateway = Spree::BillingIntegration::Ipay88.create!(:name => "Ipay88", :environment => "sandbox", :active => true)
    @gateway.preferred_merchant_key = 'TESTKEY'
    @gateway.preferred_merchant_code = 'TESTCODE'
    @gateway.preferred_currency = 'MYR'
    @gateway.save
  end

  describe "form creation" do
    it "Signature is correct" do
      @gateway.signature({order_number: 'R311814117', amount_in_cents: '9900'}).should == '4B6LGeBmttuyUhGxWkgvFqy4F1A='
    end
  end
end
