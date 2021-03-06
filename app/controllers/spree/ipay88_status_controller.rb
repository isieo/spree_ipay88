module Spree
  class Ipay88StatusController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def update
      merchant_code = params[:MerchantCode]
      payment_id = params[:PaymentId]
      reference_no = params[:RefNo]
      amount = params[:Amount]

      @order = Order.find_by_number reference_no

      unless @order.payments.where(:source_type => 'Spree::Ipay88Transaction').present?
        payment_method = PaymentMethod.find(params[:payment_method_id])
        if payment_method.remote_validation({reference_no: @order.number, amount: amount})

          ipay88_transaction = Ipay88Transaction.create_from_postback(params)

          payment = @order.payments.create({:amount => @order.total,
                                           :source => ipay88_transaction,
                                           :payment_method => payment_method})
          payment.started_processing!
          payment.complete!
        else
          redirect_to '/'
          return
        end
        if @order.state != "complete"
          @order.update_attributes({:state => "complete", :completed_at => Time.now})

          until @order.state == "complete"
            if @order.next!
              @order.update!
              state_callback(:after)
            end
          end

          @order.finalize!
        end
      end

      render :text => "RECEIVEOK"
    end

  end
end
