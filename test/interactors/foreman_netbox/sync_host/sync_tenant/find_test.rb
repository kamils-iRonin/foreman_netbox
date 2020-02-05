# frozen_string_literal: true

require 'test_plugin_helper'

class FindTenantTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncTenant::Find.call(host: host) }

  let(:host) do
    OpenStruct.new(
      owner: OpenStruct.new(
        name: 'Owner'
      )
    )
  end

  setup do
    setup_default_netbox_settings
  end

  context 'when tenant exists in Netbox' do
    it 'assigns tenant to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/tenancy/tenants.json").with(
        query: { limit: 50, slug: host.owner.name.parameterize }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            { id: 1, name: host.owner.name, slug: host.owner.name.parameterize }
          ]
        }.to_json
      )

      assert_equal 1, subject.tenant.id
      assert_requested(stub_get)
    end
  end

  context 'when tenant does not exist in NetBox' do
    it 'does not assign tenant to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/tenancy/tenants.json").with(
        query: { limit: 50, slug: host.owner.name.parameterize }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.tenant
      assert_requested(stub_get)
    end
  end
end