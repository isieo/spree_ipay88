module Spree
  class BillingIntegration::Ipay88 < BillingIntegration
    preference :account, :string
    preference :merchant_code, :string
    preference :merchant_key, :string


    def remote_validation(options)
      url = "http://www.mobile88.com/epayment/enquiry.asp"
      url += "?MerchantCode=#{url_encode(preferred_merchant_code)}"
      url += "&RefNo=#{url_encode(options[:reference_no])}"
      url += "&Amount=#{url_encode(options[:amount])}"
      response = Net::HTTP.get_response(URI.parse(url))
      if response.body == '00'
        return true
      end
      false
    end

    def signature(options)
      components  = [preferred_merchant_key]
      components << [preferred_merchant_code]
      components << [options[:order_number]]
      components << [options[:amount_in_cents]]
      components << [options[:currency]]
      [Digest::SHA1.digest(components.join)].pack("m").chomp
    end

    def source_required?
      false
    end


    def form_params(order, opts = {})
      sig = self.signature({order_number: order.number,amount_in_cents: order.total.to_s.gsub('.',''), currency: 'MYR'})
      [["MerchantCode",preferred_merchant_code],
      ["RefNo",order.number],
      ["amount",order.total.to_s.gsub('.','')],
      ["currency","MYR"],
      ["ProdDesc",'Payment for '+ order.number],
      ["Signature",sig],
      ["BackendURL",opts[:backend_url] ],
      ["ResponseURL",opts[:response_url] ]]

    end

    private

    def url_encode(param_string)
      CGI.escape(param_string)
    end
  end
end
