class PackageSimpleController < ApplicationController
  def new_package
    start_time = Time.now
    params.permit!
    new_consignee = params[:new_consignee]
    new_trackings_details = params[:new_trackings_details]
    new_trackings = params[:new_trackings]

    Consignee.insert_all(new_consignee)
    TrackingDetail.insert_all(new_trackings_details)
    Tracking.insert_all(new_trackings)

    Log.create({log_type: "tracking_simple", records_number: new_trackings.size, started_at: start_time, ended_at: Time.now, information: params[:docker_id]})
  end

  def get_depots
    render json: Depot.all.map {|depot| [depot.depot_code, depot.id]}.to_h.to_json
  end

  def create_depot
    params.permit!
    Depot.create({ depot_code: params[:code], depot_name: params[:name] })
    get_depots
  end

  def get_last_id
    last_id = 1
    if Consignee.exists?
      last_id = Consignee.last.id + 1
    end
    render json: {id: last_id}
  end
end
