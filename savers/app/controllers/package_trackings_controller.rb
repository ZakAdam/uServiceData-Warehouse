class PackageTrackingsController < ApplicationController
  def new_tracking
    start_time = Time.now
    @new_trackings = []
    @new_trackings_details = []
    @new_depot = []
    @new_consignee = []

    last_id = 1
    if Consignee.exists?
      last_id = Consignee.last.id + 1
    end

    trackings = params[:trackings]

    trackings.each do |tracking|
      parse_tracking(tracking, last_id)
      parse_trackings_detail(tracking)
      parse_consignee(tracking)
      last_id = last_id + 1
    end
    Consignee.insert_all(@new_consignee)
    TrackingDetail.insert_all(@new_trackings_details)
    Tracking.insert_all(@new_trackings)

    Log.create({log_type: "tracking", records_number: trackings.size, started_at: start_time, ended_at: Time.now})
  end

  private
  def parse_depot(code, name)
    depot_id = Depot.where(depot_code: code).first
    if depot_id.nil?
      depot_id = Depot.create({ depot_code: code, depot_name: name })
    end
    depot_id = depot_id.id
  end

  def parse_consignee(tracking)
    puts tracking[:name]
    puts tracking[:zipcode]
    puts tracking[:country_code]

    @new_consignee.append({name: tracking[:name], zipcode: tracking[:consignee_zip], country_code: tracking[:consignee_country_code]})
  end

  def parse_tracking(tracking, last_id)
    puts tracking[:parcelno]
    puts tracking[:scan_code]
    puts tracking[:event_date_time]

    @new_trackings.append({parcel_no: tracking[:parcelno],
                           scan_code: tracking[:scan_code],
                           date: DateTime.parse(tracking[:event_date_time]),
                           customer_reference: tracking[:customer_reference],
                           depot_id: parse_depot(tracking[:depot_code], tracking[:depotname]),
                           consignee_id: last_id,
                           tracking_detail_id: last_id})
  end

  def parse_trackings_detail(tracking)
    @new_trackings_details.append({service: tracking[:service],
                                   add_service_1: tracking[:add_service_1],
                                   add_service_2: tracking[:add_service_2],
                                   add_service_3: tracking[:add_service_3],
                                   info_text: tracking[:info_text],
                                   weight: tracking[:weight]
                                  })
  end
end
