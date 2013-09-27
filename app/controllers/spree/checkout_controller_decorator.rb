module Spree
  CheckoutController.class_eval do
    append_before_filter :redirect_if_ipay, only: [:update]

    def redirect_if_ipay
      if  object_params[:payments_attributes] &&
          object_params[:payments_attributes].first[:payment_method_id] &&
          PaymentMethod.find(object_params[:payments_attributes].first[:payment_method_id]).type == 'Spree::BillingIntegration::Ipay88'
        redirect_to ipay88_proxy_order_checkout_path(@order, params)
      end
    end

    def ipay88_proxy
      @payment_method = PaymentMethod.find(object_params[:payments_attributes].first[:payment_method_id])
      @ipay_params = @payment_method.form_params(@order, {response_url: ipay88_return_order_checkout_path(@order)})
    end

    def ipay88_return
      #Standard iPay
      merchant_code = params[:MerchantCode]
      payment_id = params[:PaymentId]
      reference_no = params[:RefNo]
      amount = params[:Amount]

      unless @order.payments.where(:source_type => 'Spree::Ipay88Transaction').present?
        payment_method = PaymentMethod.find(params[:payment_method_id])
        ipay88_transaction = Ipay88Transaction.create_from_postback(params)

        payment = @order.payments.create({:amount => @order.total,
                                         :source => ipay88_transaction,
                                         :payment_method => payment_method},
                                         :without_protection => true)
        payment.started_processing!
        payment.pend!
      end

      @order.update_attributes({:state => "complete", :completed_at => Time.now}, :without_protection => true)

      until @order.state == "complete"
        if @order.next!
          @order.update!
          state_callback(:after)
        end
      end

      @order.finalize!

      flash.notice = Spree.t(:order_processed_successfully)
      redirect_to completion_route

    end


    def ipay88_cancel
      flash[:error] = Spree.t(:payment_has_been_cancelled)
      redirect_to edit_order_path(@order)
    end


    private

    def confirm_ipay

    end
  end

end
