module V1
  class BusinessStatuses < Grape::API
    resource :business_status do
      before do
        authenticate_platform!
        authenticate_user!
      end

      add_desc '营业状态列表'
      params do
        requires :platform, type: String, desc: '调用的平台(app或者erp)'
      end
      get do
        present Store::BUSINESS_STATUS.to_a, with: ::Entities::BusinessStatus
      end
    end
  end
end
