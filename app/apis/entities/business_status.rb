module Entities
  class BusinessStatus < Grape::Entity
    expose(:code) { |status, options| status.first }
    expose(:name) { |status, options| status.last }
  end
end
