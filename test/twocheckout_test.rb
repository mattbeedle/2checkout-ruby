require_relative "minitest_helper"

#
# Sales
#
describe Twocheckout::Sale do

  #retrieve sale
  it "Sale retrieve returns sale" do
    sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
    assert_equal('9093717691800', sale.sale_id)
  end

  #retrieve invoice
  it "Sale retrieve returns invoice" do
    invoice = Twocheckout::Sale.find({:invoice_id => 9093717691821})
    assert_equal('9093717691821', invoice.invoice_id)
  end

  #retrieve sale list
  it "Sale list returns list" do
    sale_list = Twocheckout::Sale.list({:pagesize => 5})
    assert_equal(5, sale_list.size)
  end

  #refund sale
  it "Refunding a refunded sale returns Twocheckout::TwocheckoutError" do
    begin
      sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
      sale.refund!({:comment => "test refund", :category => 1})
    rescue Twocheckout::TwocheckoutError => e
      assert_equal("Invoice was already refunded.", e.message)
    end
  end

  #refund invoice
  it "Refunding a refunded invoice returns Twocheckout::TwocheckoutError" do
    begin
      sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
      invoice = sale.invoices.first
      invoice.refund!({:comment => "test refund", :category => 1})
    rescue Twocheckout::TwocheckoutError => e
      assert_equal("Invoice was already refunded.", e.message)
    end
  end

  #refund lineitem
  it "Refunding a refunded lineitem returns Twocheckout::TwocheckoutError" do
    begin
      sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
      first_invoice = sale.invoices.first
      last_lineitem = first_invoice.lineitems.last
      last_lineitem.refund!({:comment => "test refund", :category => 1})
    rescue Twocheckout::TwocheckoutError => e
      assert_equal("This lineitem cannot be refunded.", e.message)
    end
  end

  #stop recurring lineitem
  it "Stopping a stopped recurring lineitem returns Twocheckout::TwocheckoutError" do
    begin
      sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
      result = sale.stop_recurring!
      assert_equal(result, [])
    rescue Twocheckout::TwocheckoutError => e
      assert_equal("Lineitem is not scheduled to recur.", e.message)
    end
  end

  #stop recurring sale
  it "Stopping a stopped recurring sale returns Twocheckout::TwocheckoutError" do
    begin
      sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
      last_invoice = sale.invoices.last
      last_lineitem = last_invoice.lineitems.last
      last_lineitem.stop_recurring!
    rescue Twocheckout::TwocheckoutError => e
      assert_equal("Lineitem is not scheduled to recur.", e.message)
    end
  end

  #create comment
  it "Creates a sale comment" do
    sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
    result = sale.comment({:sale_comment => "test"})
    assert_equal('Created comment successfully.', result['response_message'])
  end

  #mark shipped
  it "Shipping an intangible sale returns Twocheckout::TwocheckoutError" do
    begin
      sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
      sale.ship({:tracking_number => "123"})
    rescue Twocheckout::TwocheckoutError => e
      assert_equal("Sale already marked shipped.", e.message)
    end
  end

  #reauth
  it "Reauthorizing a pending sale returns Twocheckout::TwocheckoutError" do
    begin
      sale = Twocheckout::Sale.find(:sale_id => 9093717691800)
      sale.reauth
    rescue Twocheckout::TwocheckoutError => e
      assert_equal("Payment is already pending or deposited and cannot be reauthorized.", e.message)
    end
  end
end

#
# Products
#

describe Twocheckout::Product do

  # Product list
  it "Product list returns array of products" do
    product_list = Twocheckout::Product.list({ :pagesize => 3 })
    assert_equal(product_list.size, 3)
  end

  # Product CRUD
  it "Product create, find, update, delete is successful" do
    # create
    new_product = Twocheckout::Product.create({:name => "test product", :price => 1.00})
    assert_equal("test product", new_product.name)
    # find
    product = Twocheckout::Product.find({:product_id => new_product.product_id})
    assert_equal(new_product.product_id, product.product_id)
    # update
    product = product.update({:name => "new name"})
    assert_equal("new name", product.name)
    # delete
    result = product.delete!
    assert_equal("Product successfully deleted.", result['response_message'])
  end
end

describe Twocheckout::Option do

  # Option list
  it "Option list returns array of options" do
    option_list = Twocheckout::Option.list({ :pagesize => 3 })
    assert_equal(3, option_list.size)
  end

  # Option CRUD
  it "Option create, find, update, delete is successful" do
    # create
    new_option = Twocheckout::Option.create({:option_name => "test option",
                                             :option_value_name => "test option value", :option_value_surcharge => 1.00})
    assert_equal("test option", new_option.option_name)
    # find
    option = Twocheckout::Option.find({:option_id => new_option.option_id})
    assert_equal(new_option.option_id, option.option_id)
    # update
    option = option.update({:option_name => "new name"})
    assert_equal("new name", option.option_name)
    # delete
    result = option.delete!
    assert_equal("Option deleted successfully", result['response_message'])
  end
end

describe Twocheckout::Coupon do

  # Coupon list
  it "Coupon list returns array of coupons" do
    coupon_list = Twocheckout::Coupon.list({ :pagesize => 4 })
    assert_equal(4, coupon_list.size)
  end

  # Coupon CRUD
  it "Coupon create, find, update, delete is successful" do
    # create
    new_coupon = Twocheckout::Coupon.create({:date_expire => "2020-01-01",
                                             :type => "shipping", :minimum_purchase => 1.00})
    assert_equal("2020-01-01", new_coupon.date_expire)
    # find
    coupon = Twocheckout::Coupon.find({:coupon_code => new_coupon.coupon_code})
    assert_equal(new_coupon.coupon_code, coupon.coupon_code)
    # update
    coupon = coupon.update({:date_expire => "2020-01-02"})
    assert_equal("2020-01-02", coupon.date_expire)
    # delete
    result = coupon.delete!
    assert_equal("Coupon successfully deleted.", result['response_message'])
  end
end

describe Twocheckout::ValidateResponse do
  #demo
  it "Validates Purchase MD5 Hash" do
    result = Twocheckout::ValidateResponse.purchase({:sid => 1817037, :secret => "tango", :order_number => 1, :total => 0.01,
                                                     :key => '1BC47EA0D63EB76496E294F434138AD3'})
    assert_equal('PASS', result[:code])
  end

  #purchase
  it "Validates Purchase MD5 Hash" do
    result = Twocheckout::ValidateResponse.purchase({:sid => 1817037, :secret => "tango", :order_number => 4789848870, :total => 0.01,
                                                     :key => 'CDF3E502AA1597DD4401760783432337'})
    assert_equal('PASS', result[:code])
  end

  #notification
  it "Validates Notification MD5 Hash" do
    result = Twocheckout::ValidateResponse.notification({:sale_id => 4789848870, :vendor_id => 1817037, :invoice_id => 4789848879, :secret => "tango",
                                                         :md5_hash => '827220324C722873694758F38D8D3624'})
    assert_equal('PASS', result[:code])
  end
end

describe Twocheckout::Checkout do
  #submit
  it "Submit return a form + JS to submit" do
    form = Twocheckout::Checkout.submit({ 'sid' => '1817037', 'cart_order_id' => 'Example Sale', 'total' => '1.00'})
    @form = "<form id=\"2checkout\" action=\"https://sandbox.2checkout.com/checkout/purchase\" method=\"post\">\n" +
      "<input type=\"hidden\" name=\"sid\" value=\"1817037\" />\n" +
      "<input type=\"hidden\" name=\"cart_order_id\" value=\"Example Sale\" />\n" +
      "<input type=\"hidden\" name=\"total\" value=\"1.00\" />\n" +
      "</form>\n" +
      "<script type=\"text/javascript\">document.getElementById('2checkout').submit();</script>"
    assert_equal(form, @form)
  end

  #form
  it "Form returns a form" do
    form = Twocheckout::Checkout.form({ 'sid' => '1817037', 'cart_order_id' => 'Example Sale', 'total' => '1.00'}, "Proceed")
    @form = "<form id=\"2checkout\" action=\"https://sandbox.2checkout.com/checkout/purchase\" method=\"post\">\n" +
      "<input type=\"hidden\" name=\"sid\" value=\"1817037\" />\n" +
      "<input type=\"hidden\" name=\"cart_order_id\" value=\"Example Sale\" />\n" +
      "<input type=\"hidden\" name=\"total\" value=\"1.00\" />\n" +
      "<input type=\"submit\" value=\"Proceed\" />\n" +
      "</form>"
    assert_equal(form, @form)
  end

  #direct
  it "Direct returns a form and js" do
    form = Twocheckout::Checkout.direct({ 'sid' => '1817037',
                                          'cart_order_id' => 'Example Sale',
                                          'total' => '1.00',
                                          'card_holder_name' => 'Testing Tester',
                                          'street_address' => '123 Test St',
                                          'city' => 'Columbus',
                                          'state' => 'Ohio',
                                          'zip' => '43123',
                                          'country' => 'USA',
                                          'email' => 'no-reply@2co.com'
    })
    @form = "<form id=\"2checkout\" action=\"https://sandbox.2checkout.com/checkout/purchase\" method=\"post\">\n" +
      "<input type=\"hidden\" name=\"sid\" value=\"1817037\" />\n" +
      "<input type=\"hidden\" name=\"cart_order_id\" value=\"Example Sale\" />\n" +
      "<input type=\"hidden\" name=\"total\" value=\"1.00\" />\n" +
      "<input type=\"hidden\" name=\"card_holder_name\" value=\"Testing Tester\" />\n" +
      "<input type=\"hidden\" name=\"street_address\" value=\"123 Test St\" />\n" +
      "<input type=\"hidden\" name=\"city\" value=\"Columbus\" />\n" +
      "<input type=\"hidden\" name=\"state\" value=\"Ohio\" />\n" +
      "<input type=\"hidden\" name=\"zip\" value=\"43123\" />\n" +
      "<input type=\"hidden\" name=\"country\" value=\"USA\" />\n" +
      "<input type=\"hidden\" name=\"email\" value=\"no-reply@2co.com\" />\n" +
      "<input type=\"submit\" value=\"Proceed to Checkout\" />\n" +
      "</form>\n" +
      "<script src=\"https://www.2checkout.com/static/checkout/javascript/direct.min.js\"></script>"
    assert_equal(form, @form)
  end

  #link
  it "Link returns a link" do
    link = Twocheckout::Checkout.link({ 'sid' => '1817037', 'cart_order_id' => 'Example Sale', 'total' => '1.00'})
    @link = "https://sandbox.2checkout.com/checkout/purchase?sid=1817037&cart_order_id=Example+Sale&total=1.00"
    assert_equal(link, @link)
  end

  #authorize
  it "Authorize creates authorization" do
    params = {
      :merchantOrderId     => '123',
      :token          => 'MjQ3YTM2NDEtMmNiNC00ZGM3LTljZDItZjIxMzllYWE5ZmNl',
      :currency       => 'USD',
      :total          => '1.00',
      :billingAddr    => {
        :name => 'Testing Tester',
        :addrLine1 => '123 Test St',
        :city => 'Columbus',
        :state => 'OH',
        :zipCode => '43123',
        :country => 'USA',
        :email => 'cchristenson@2co.com',
        :phoneNumber => '555-555-5555'
      }
    }
    begin
      result = Twocheckout::Checkout.authorize(params)
      assert_equal("APPROVED", result['responseCode'])
    rescue Twocheckout::TwocheckoutError => e
      assert_equal("Unauthorized", e.message)
    end
  end
end
