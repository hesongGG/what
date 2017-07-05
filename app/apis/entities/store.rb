module Entities
  class Store < Grape::Entity
    expose :id, :name
    expose :customer_categories do |store, options|
      store.store_customer_categories.map do |category|
        {
          id: category.id,
          name: category.name
        }
      end
    end
    expose :commission
    expose :departments do |store, options|
      store.store_departments.map do |department|
        {
          id: department.id,
          name: department.name,
          positions: department.store_positions.map do |position|
            {
              id: position.id,
              name: position.name
            }
          end
        }
      end
    end
    expose :admin do |store, options|
      {
        first_name: store.admin.try(:first_name),
        last_name: store.admin.try(:last_name)
      }
    end
    expose :province
    expose :city
    expose(:position) { |store, options| store.info_by('经纬度') }
    expose(:phone_number) { |store, options| store.admin.try(:phone_number) }
    expose :address
    expose(:created_at) { |store, options| store.created_at.strftime('%Y-%m-%d') }
    expose :business_status
    expose(:on_duty_at) { |store, options| store.info_by('上班时间') }
    expose(:off_duty_at) { |store, options| store.info_by('下班时间') }
    expose :last_year_sales
    expose :current_year_sales

    private

      def commission
        StoreStaffLevel::ID_TYPES
      end

  end
end
