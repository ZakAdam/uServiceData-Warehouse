class RowSaveController < ApplicationController
  def process_data
    data = params[:data]
    supplier = params[:supplier]
    rows = []
    data.split('\n').each do |row|
      rows.append({ row: row, supplier: supplier })
    end

    Row.insert_all(rows)
  end
end
