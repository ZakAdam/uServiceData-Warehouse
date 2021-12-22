class GlsProcessorsController < ApplicationController
  def transform
    file = Roo::Spreadsheet.open(params[:file], extension: :xls)

    rows = file.parse(headers: true)
    transform = rows.map do |row|
      {
        package_number: row['Číslo balíka'],
        invoice_number: row['InvoiceNo'],
        carrier: 'gls',
        invoice_date: row['InvoiceDate'],
        delivery_date: row['DeliverDate'],
        fees: row['TollFee'] + row['Diesel Fee'] + row['TransportFee'] + row['SVFee'] + row['CodFee'] + row['OverWeightFee'] + row['ExpressFee'] + row['CreditCardFee'] + row['ManualLabelFee'],
        country: row['Štát'],
        customer: get_customer_name(row['PostalAddr'].to_s),
        city: row['Mesto'],
        zipcode: row['PSČ'],
        address: row['PostalAddr']

      }
    end

    puts transform[1]
    render json: { first_zaznam: transform[1] }
    #puts transform

  end

  private
  def get_customer_name(row)
    name = row.split('     ')
    #puts name[0]
    name[0]
  end
end
