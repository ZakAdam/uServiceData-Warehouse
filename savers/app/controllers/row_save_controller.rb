class RowSaveController < ApplicationController
  def process_data
    start_time = Time.now

    last_row_id = 1
    last_row_id = Row.last.id + 1 if Row.exists?

    data = params[:data]

    rows = []
    data.each do |row|
      rows << { id: last_row_id, row: row.to_s }
      last_row_id += 1
    end
    Row.insert_all(rows)

    Log.create({ log_type: 'rows', records_number: data.size, started_at: start_time, ended_at: Time.now, information: params[:docker_id] })
  end
end
