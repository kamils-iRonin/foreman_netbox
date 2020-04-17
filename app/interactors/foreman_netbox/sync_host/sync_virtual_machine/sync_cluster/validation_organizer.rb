# frozen_string_literal: true

module ForemanNetbox
  module SyncHost
    module SyncVirtualMachine
      module SyncCluster
        class ValidationOrganizer
          include ::Interactor::Organizer

          organize SyncCluster::SyncClusterType::Validate,
                   SyncCluster::Validate
        end
      end
    end
  end
end
