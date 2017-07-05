module Entities
  class Vehicle < Grape::Entity
    expose :basic_info do
      expose :id
      expose :license_number
      expose :identification_number
      expose :vin
      expose(:vehicle_brand){ |vehicle, options| vehicle.vehicle_brand.try(:name) }
      expose(:vehicle_model){ |vehicle, options| vehicle.vehicle_model.try(:name) }
      expose(:vehicle_series){ |vehicle, options| vehicle.vehicle_series.try(:name) }
      expose :operator
      expose(:created_at){ |vehicle, options| vehicle.created_at.strftime('%Y-%m-%d') }
      expose :color
      expose :capacity
      expose :organization_type
      expose :bought_on
      expose :ex_factory_date
      expose :registered_on
      expose :mileage
    end

    expose :detail do
      expose(:numero){ |vehicle, options| vehicle.detail_by('numero') }
      expose :maintained_at
      expose :maintained_mileage
      expose :maintain_interval_time
      expose :maintain_interval_mileage
      expose :next_maintain_mileage
      expose :next_maintain_at
      expose :annual_check_at
      expose :insurance_compnay
      expose :insurance_expire_at
      expose(:next_maintain_customer_alermify) {|model| model.next_maintain_customer_alermify == 1 ? true : false}
      expose(:next_maintain_store_alermify) {|model| model.next_maintain_store_alermify == 1 ? true : false}

      expose(:annual_check_customer_alermify) {|model| model.annual_check_customer_alermify == 1 ? true : false}
      expose(:annual_check_store_alermify) {|model| model.annual_check_store_alermify == 1 ? true : false}
      expose(:insurance_customer_alermify) {|model| model.insurance_customer_alermify == 1 ? true : false}
    end

    expose :damages

    expose :orders, using: ::Entities::Order

    private

      def damages
        object.orders.order('created_at desc').map do |order|
          order.damages.map do |damage|
            {
              created_at: order.created_at.strftime('%Y-%m-%d'),
              content: damage['content']
            }
          end
        end.flatten!
      end

      def organization_type
        object.try(:organization_type_name)
      end

  end
end
