module Doorkeeper
  class OauthResourceOwnerAuthenticator
    attr_reader :application, :request

    delegate :params, to: :request

    def self.authenticate(*args, &block)
      new(*args).authenticate(&block)
    end

    def initialize(application, request)
      @application = application
      @request = request
    end

    def authenticate
      owner = owner_class.find_for_database_authentication(email: params[:username])
      return unless owner

      password = (params[:password] || '').split("\n").first
      is_authenticated = if owner.respond_to?(:valid_for_authentication?)    # devise models
                           owner.valid_for_authentication? { owner.valid_password?(password) }
                         else                                                # non-devise models
                           owner.valid_password?(password)
                         end

      is_authenticated &&= yield(owner) if block_given?        # custom authentication given as a block
      return unless is_authenticated

      OauthResourceOwner.find_or_create_by(owner: owner)
    end

    private

    def owner_class
      raise 'params must contain :owner_type for polymorphic resource_owners' unless params[:owner_type].present?
      params[:owner_type].classify.constantize
    end
  end
end
