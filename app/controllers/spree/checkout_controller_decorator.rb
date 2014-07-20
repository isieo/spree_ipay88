module Spree
  CheckoutController.class_eval do
    append_before_filter :redirect_if_ipay, only: [:update]
    skip_before_filter :verify_authenticity_token, only: [:ipay88_proxy, :ipay88_return, :ipay88_cancel]

    def redirect_if_ipay
      if  params[:order][:payments_attributes] &&
          params[:order][:payments_attributes].first[:payment_method_id] &&
          PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id]).type == 'Spree::BillingIntegration::Ipay88'
        redirect_to ipay88_proxy_order_checkout_path(@order, params)
      end
    end

    def ipay88_proxy
      @payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      @ipay_params = @payment_method.form_params(@order, {response_url: ipay88_return_order_checkout_url(@order, payment_method_id: @payment_method.id),backend_url: ipay88_url(payment_method_id: @payment_method.id) })
    end

    def ipay88_return
      #Standard iPay
      merchant_code = params[:MerchantCode]
      payment_id = params[:PaymentId]
      reference_no = params[:RefNo]
      amount = params[:Amount]
      if params[:ErrDesc] && !params[:ErrDesc].empty?
        flash[:error] = params[:ErrDesc]
        redirect_to edit_order_checkout_path(@order)
        return
      end


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

        end
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

      flash.notice = Spree.t(:order_processed_successfully)
      redirect_to order_path(@order)

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
