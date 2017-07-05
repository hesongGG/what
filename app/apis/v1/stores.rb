module V1
  class Stores < Grape::API
    resource :stores do
      before do
        authenticate_platform!
        authenticate_user!
      end

      add_desc '门店列表'

      params do
        requires :platform, type: String, desc: '调用的平台(app或者erp)'
        optional :q, type: Hash, default: {} do
          optional :name_cont, type: String, desc: "门店名称"
          optional :province, type: String, desc: "省份code"
          optional :city, type: String, desc: "城市code"
          optional :created_at, type: String, desc: "创建时间"
        end
      end

      get do
        q = current_store_chain.stores.ransack(search_q_params)
        present q.result(district: true).order('id asc'), with: ::Entities::Store
      end

      add_desc '创建分店'
      params do
        requires :platform, type: String, desc: '调用的平台(app或者erp)'
        requires :store, type: Hash, default: {} do
          requires :name, type: String, desc: "门店名称"
          optional :business_status, type: String, desc: "营业状态"

          requires :store_infos, type: Hash, default: {} do
            optional :provinces, type: String, desc: '省份code'
            optional :city, type: String, desc: '城市code'
            optional :detail, type: String, desc: '详细地址'
            requires :mobile, type: String, desc: '联系电话'
            optional :position, type: String, desc: '门店坐标'
            optional :work, type: String, desc: '上班时间'
            optional :chapman, type: String, desc: '下班时间'
          end

          requires :admin, type: Hash, default: {} do
            requires :first_name, type: String, desc: '名'
            requires :last_name, type: String, desc: '姓'
          end

        end

      end

      post do
        if CreateStoreService.call(params[:store], current_store_chain.id)
          { notice: true }
        else
          { notice: false }
        end
      end

      add_desc '单个门店'
      params do
        requires :platform, type: String, desc: '调用的平台(app或者erp)'
        requires :id, type: Integer, desc: '门店id'
      end

      get ':id' do
        store = current_store_chain.stores.find(params[:id])
        present store, with: ::Entities::Store
      end

    end

    helpers do
      def search_q_params
        category_name = params[:q].has_key?(:city) ? '城市' : '省份'
        current_time = Time.zone.parse(params[:q][:created_at] || "")
        params[:q].merge({
          store_infos_info_category_id_eq: InfoCategory.find_by(name: category_name).id,
          store_infos_value_eq: params[:q][:city] || params[:q][:province],
          created_at_gteq: current_time.try(:beginning_of_day),
          created_at_lteq: current_time.try(:end_of_day)
        }).except(:province, :city, :created_at)
      end
    end

  end
end
