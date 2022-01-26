class PackageTrackingsController < ApplicationController
  def new_tracking
    @new_trackings = []
    @new_trackings_info = []
    @new_depot = []
    @new_consignee = []
    @new_services = []

    last_id = 1
    if Consignee.exists?
      last_id = Consignee.last.id + 1
    end
    last_tracking_info_id = 1
    if TrackingInfo.exists?
      last_tracking_info_id = TrackingInfo.last.id + 1
    end

    trackings = params[:trackings]
    
    trackings.each do |tracking|
      parse_tracking(tracking, last_id)
      parse_services(tracking)
      parse_depot(tracking[:depot_code], tracking[:depotname])
      parse_consignee(tracking)
      last_id = last_id + 1
    end
    Consignee.insert_all(@new_consignee)
    Service.insert_all(@new_services)
    Tracking.insert_all(@new_trackings)
  end

  private
  def parse_depot(code, name)
    puts code
    puts name
    #@new_depot.append({depot_code: code, depot_name: name})
  end

  def parse_services(tracking)
    @new_services.append({service: tracking[:service],
                          add_service_1: tracking[:add_service_1],
                          add_service_2: tracking[:add_service_2],
                          add_service_3: tracking[:add_service_3]
                         })
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
                           depot_id: nil,
                           consignee_id: last_id,
                           service_id: last_id,
                           tracking_info_id: nil})
  end

  def parse_trackings_info
    puts 'info'
  end
end
