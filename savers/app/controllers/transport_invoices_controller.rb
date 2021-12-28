class TransportInvoicesController < ApplicationController
  def new_invoice
    @new_dates = []
    @new_customers = []
    data = params[:file]

    data.each do |row|
      unless Country.where(code: row['country']).exists?
        unless row['country'].nil? or row['country'].length > 2
          Country.create({ name: nil, code: row['country'] })
        end
      end
      date_process(row['invoice_date'], row['delivery_date'])
      customer_process(row)
    end
    NewDate.insert_all(@new_dates)
    Customer.insert_all(@new_customers)
    @new_dates = []
    @new_customers = []
  end


  def date_process(invoice_date, delivery_date)
    begin
      new_invoice = Date.parse(invoice_date).strftime("%Y-%m-%d")
      new_delivery = Date.parse(delivery_date).strftime("%Y-%m-%d")
    rescue Date::Error
      puts "Wrong format of date string."
      return
    rescue TypeError
      puts "Nil is not being stored to DB."
      return
    end
    @new_dates.append({delivery_date: new_delivery, invoice_date: new_invoice})
  end


  def customer_process(row)
    new_zip = nil
    unless row['zipcode'].nil?
      new_zip = row['zipcode'][0...-2]
    end
    @new_customers.append({name: row['customer'], city: row['city'], zipcode: new_zip, address: row['address']})
  end
end