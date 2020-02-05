# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncCluster
      class Find
        include ::Interactor

        def call
          context.cluster = ForemanNetbox::API.client.virtualization.clusters.find_by(params)
        rescue NetboxClientRuby::LocalError, NetboxClientRuby::ClientError, NetboxClientRuby::RemoteError => e
          Foreman::Logging.exception("#{self.class} error:", e)
          context.fail!(error: "#{self.class}: #{e}")
        end

        private

        def params
          {
            name: context.host.compute_object&.cluster
          }
        end
      end
    end
  end
end