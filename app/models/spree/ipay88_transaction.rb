module Spree
  class Ipay88Transaction < ActiveRecord::Base
    has_many :payments, :as => :source

    def actions
      []
    end

    def self.create_from_postback(params)
       Ipay88Transaction.create(:merchant_code => params[:MerchantCode],
                               :payment_id => params[:PaymentId],
                               :ref_no => params[:RefNo],
                               :amount => params[:Amount],
                               :currency => params[:Currency],
                               :customer_id => params[:Remark],
                               :trans_id => params[:TransId],
                               :authcode => params[:AuthCode],
                               :status => params[:Status],
                               :error_description => params[:ErrDesc],
                               :signature => params[:Signature])
    end

  end
end
