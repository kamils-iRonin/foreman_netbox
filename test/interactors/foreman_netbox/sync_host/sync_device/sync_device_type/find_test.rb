# frozen_string_literal: true

require 'test_plugin_helper'

class FindDeviceTypeTest < ActiveSupport::TestCase
  subject { ForemanNetbox::SyncHost::SyncDevice::SyncDeviceType::Find.call(host: host) }

  let(:host) do
    OpenStruct.new(
      facts: {
        'dmi::product::name': 'Device type'
      }
    )
  end
  let(:slug) { host.facts.symbolize_keys.fetch(:'dmi::product::name').parameterize }

  setup do
    setup_default_netbox_settings
  end

  context 'when device_type exists in Netbox' do
    it 'assigns device_type to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/dcim/device-types.json").with(
        query: { limit: 50, slug: slug }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 1,
          results: [
            {
              id: 1,
              name: host.facts.symbolize_keys.fetch(:'dmi::product::name'),
              slug: slug
            }
          ]
        }.to_json
      )

      assert_equal 1, subject.device_type.id
      assert_requested(stub_get)
    end
  end

  context 'when device_type does not exist in NetBox' do
    it 'does not assign device_type to context' do
      stub_get = stub_request(:get, "#{Setting[:netbox_url]}/dcim/device-types.json").with(
        query: { limit: 50, slug: slug }
      ).to_return(
        status: 200, headers: { 'Content-Type': 'application/json' },
        body: {
          count: 0,
          results: []
        }.to_json
      )

      assert_nil subject.device_type
      assert_requested(stub_get)
    end
  end
end