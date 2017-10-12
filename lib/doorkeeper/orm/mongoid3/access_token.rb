require 'doorkeeper/orm/mongoid3/concerns/scopes'

module Doorkeeper
  class AccessToken
    include Mongoid::Document
    include Mongoid::Timestamps

    include AccessTokenMixin
    include Models::Mongoid3::Scopes

    self.store_in collection: :oauth_access_tokens

    field :resource_owner_id, type: Moped::BSON::ObjectId
    field :application_id, type: Moped::BSON::ObjectId
    field :token, type: String
    field :refresh_token, type: String
    field :expires_in, type: Integer
    field :revoked_at, type: DateTime

    belongs_to :resource_owner, class_name: 'Doorkeeper::OauthResourceOwner'

    index({ token: 1 }, { unique: true })
    index({ refresh_token: 1 }, { unique: true, sparse: true })

    def self.delete_all_for(application_id, resource_owner)
      where(application_id: application_id,
            resource_owner_id: resource_owner.id).delete_all
    end
    private_class_method :delete_all_for

    def self.order_method
      :order_by
    end

    def self.created_at_desc
      [:created_at, :desc]
    end

    def as_json(*)
      super.except!(:resource_owner_id).merge!(
        owner: {
          id: resource_owner.try(:owner_id),
          type: resource_owner.try(:owner_type).try(:tableize)
        }
      )
    end
  end
end
