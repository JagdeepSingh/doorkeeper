module Doorkeeper
  class OauthResourceOwner
    include Mongoid::Document
    include Mongoid::Timestamps

    self.store_in collection: :oauth_resource_owners

    belongs_to :owner, polymorphic: true
  end
end
