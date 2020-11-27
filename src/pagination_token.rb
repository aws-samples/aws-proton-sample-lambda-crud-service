# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

require 'aws-record'
require 'time'

class PaginationToken
  include Aws::Record
  set_table_name ENV["TABLE_NAME"]

  # Defined Attributes
  string_attr :uuid, hash_key: true, database_attribute_name: 'hk'
  string_attr :table_name, range_key: true, database_attribute_name: 'rk'
  epoch_time_attr :ttl

  # Domain-Specific Attributes
  map_attr :exclusive_start_key

  def self.generate(exclusive_start_key)
    item = new(
      uuid: SecureRandom.uuid,
      table_name: 'TOKEN',
      ttl: (Time.now + 86400), # TTL: One Day
      exclusive_start_key: exclusive_start_key
    )
    item.save ? item.uuid : nil
  end

  def self.unwrap(uuid)
    item = find(uuid: uuid, table_name: 'TOKEN')
    if item
      item.exclusive_start_key
    else
      nil
    end
  end
end
