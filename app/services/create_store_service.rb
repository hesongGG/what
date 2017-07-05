class CreateStoreService
  include Serviceable

  def initialize(store_params, store_chain_id)
    @store = store_params
    @store_chain_id = store_chain_id
  end

  def call
    ActiveRecord::Base.transaction do
      store = Store.create!(
        name: @store[:name],
        business_status: @store[:business_status],
        store_chain_id: @store_chain_id
      )
      admin = StoreStaff.create!(
        first_name: @store[:admin][:first_name],
        last_name: @store[:admin][:last_name],
        login_name: @store[:store_infos][:mobile],
        phone_number: @store[:store_infos][:mobile],
        password: @store[:store_infos][:mobile][5..-1],
        store_chain_id: @store_chain_id,
        store_id: store.id
      )
      admin.encrypted_password
      store.update!(admin_id: admin.id)
      @store[:store_infos].each do |key, value|
        store.store_infos.create!(
          info_category_id: InfoCategory.find_by(code: key).id,
          value: value,
          store_chain_id: @store_chain_id,
        )
      end

      init_default_organizational_structure(store)
      init_default_settlement_account(store)
      init_default_depot(store)
      send_create_store_msg(store)
    end
    true
  rescue ActiveRecord::RecordNotSaved => e
    Rails.logger.error e.message
    false

  end

  def init_default_organizational_structure(store)
    department = store.store_departments.create!(
      name: '默认部门',
      store_chain_id: @store_chain_id,
      store_staff_id: store.admin_id
    )
    department.store_positions.create!(
      name: '默认职位',
      store_id: store.id,
      store_chain_id: @store_chain_id,
      store_staff_id: store.admin_id
    )
  end

  def init_default_settlement_account(store)
    store
      .store_settlement_accounts
        .create name: '默认结算账户',
                store_chain_id: @store_chain_id,
                store_staff_id: store.admin_id
  end

  def init_default_depot(store)
    store
      .store_depots
        .create name: '默认仓库',
                store_chain_id: @store_chain_id,
                store_staff_id: store.admin_id,
                preferred: true,
                admin_ids: [store.admin_id]

  end

  def send_create_store_msg(store)
    SmsClient.publish(store.admin.phone_number, Setting.message.new_store)
  rescue Exception => e
    Rails.logger.error e.message
    true
  end
end
