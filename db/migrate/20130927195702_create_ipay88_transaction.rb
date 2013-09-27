class CreateIpay88Transaction < ActiveRecord::Migration
  def change
    create_table :ipay88_transactions do |t|
      t.string :trans_id
      t.string :authcode
      t.string :status
      t.string :error_description
      t.string :signature
      t.string :currency
      t.string :amount
      t.string :ref_no
      t.string :payment_id
      t.string :customer_id
      t.string :merchant_code
    end
  end
end
