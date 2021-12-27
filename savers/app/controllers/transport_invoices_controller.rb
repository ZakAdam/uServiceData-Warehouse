class TransportInvoicesController < ApplicationController
  def new_invoice
    data = params[:file]

    data.each do |row|
      unless Country.where(code: row['country']).exists?
        unless row['country'].nil? or row['country'].length > 2
          Country.create({ name: nil, code: row['country'] })
        end
      end
    end
  end
end