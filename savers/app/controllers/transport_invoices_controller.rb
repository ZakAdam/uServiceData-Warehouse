class TransportInvoicesController < ApplicationController
  def new_invoice
    start_time = Time.now
    @countries = Country.all.map {|country| [country.code, country.id]}.to_h
    @carriers = Carrier.all.map {|carrier| [carrier.name, carrier.id]}.to_h
    @new_dates = []
    @new_customers = []
    @new_invoice = []
    date_id = 1
    customer_id = 1
    if NewDate.exists?              # Does customer also exists?
      date_id = NewDate.last.id + 1
      customer_id = Customer.last.id + 1
    end
    data = params[:file]
    data.pop                        # Remove last element
    data.shift                      # Remove first element

    data.each do |row|
      date_process(row['invoice_date'], row['delivery_date'])
      customer_process(row)
      invoice_process(row, date_id, customer_id)
      date_id = date_id + 1
      customer_id = customer_id + 1
    end
    NewDate.insert_all(@new_dates)
    Customer.insert_all(@new_customers)
    Invoice.insert_all(@new_invoice)

    Log.create({log_type: "invoice", records_number: data.size, started_at: start_time, ended_at: Time.now, information: params[:docker_id], jid: params[:jid]})
    @new_dates = []
    @new_customers = []
    @new_invoice = []
  end

  def invoice_process(row, date_id, customer_id)
    country_id = @countries["#{row['country']}"]

    if country_id.nil?
      country_id = Country.create({ name: nil, code: row['country'] })
      @countries = Country.all.map {|country| [country.code, country.id]}.to_h
    end

    carrier_id = @carriers["#{row['carrier']}"]
    if carrier_id.nil?
      carrier_id = Carrier.create(name: row['carrier'])
      @carriers = Carrier.all.map {|carrier| [carrier.name, carrier.id]}.to_h
    end

    @new_invoice.append({customer_id: customer_id, date_id: date_id, carrier_id: carrier_id, country_id: country_id, price: row['price'], fees: row['fees'], cash_on_delivery: row['delivery_cash']})
  end


  def date_process(invoice_date, delivery_date)
    begin
      new_invoice = Date.parse(invoice_date).strftime("%Y-%m-%d")
      new_delivery = Date.parse(delivery_date).strftime("%Y-%m-%d")
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