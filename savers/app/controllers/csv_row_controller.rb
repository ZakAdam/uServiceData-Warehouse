class CsvRowController < ApplicationController
  def store_data
    start_time = Time.now

    data = params[:data]

    array_store = []
    data.each do |row|
      array_store << { row: row }
    end
    CsvRow.insert_all(array_store)

    Log.create({ log_type: "csv_data", records_number: data.size, started_at: start_time, ended_at: Time.now, information: params[:docker_id] })
  end
end
