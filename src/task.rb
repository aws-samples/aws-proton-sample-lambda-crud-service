# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

require_relative 'pagination_token'
require_relative 'errors'
require 'aws-record'
require 'active_model'
require 'securerandom'
require 'time'

class Task
  include Aws::Record
  include ActiveModel::Validations
  set_table_name ENV["TABLE_NAME"]

  # Defined Attributes
  string_attr :task_id, hash_key: true, database_attribute_name: 'hk'
  string_attr :table_name, range_key: true, database_attribute_name: 'rk'

  # Domain-Specific Attributes
  string_attr :title
  string_attr :description, default_value: ""
  string_attr :status
  epoch_time_attr :created_at
  epoch_time_attr :updated_at

  # Validations
  validates_presence_of :title, :description, :status, :created_at, :updated_at
  validates_inclusion_of :status, in: %w( BACKLOG TODO WIP BLOCKED REVIEW DONE CANCELLED )
  validates_length_of :title, within: 2..128
  validates_length_of :description, maximum: 2048

  # Indexes
  global_secondary_index(
    :reverse,
    hash_key: :table_name,
    range_key: :task_id,
    projection: {
      projection_type: "ALL"
    }
  )

  def to_json(_)
    {
      task_id: self.task_id,
      title: self.title,
      description: self.description,
      status: self.status,
      created_at: self.created_at.utc.to_s,
      updated_at: self.updated_at.utc.to_s
    }.to_json
  end

  def self.get_task(task_id:)
    item = find(task_id: task_id, table_name: "TASK")
    if item
      [item, nil]
    else
      [nil, TaskNotFoundException.new(task_id)]
    end
  end

  def self.delete_task(task_id:)
    item = find(task_id: task_id, table_name: "TASK")
    if item
      item.delete! # any error is a 500 error, so pass through
    else
      [nil, TaskNotFoundException.new(task_id)]
    end
  end

  def self.create_task(title:,description:,status:)
    now = Time.now
    item = new(
      task_id: "#{now.to_i}_#{SecureRandom.uuid}",
      table_name: "TASK",
      title: title,
      description: description,
      status: status,
      created_at: now,
      updated_at: now
    )
    if item.save
      [item, nil]
    else
      if item.valid? # server error
        puts "[ERROR] Unknown issue trying to write valid item #{item.to_h} to app table."
        [nil, ServerError.new]
      else # validation error
        [nil, InvalidInputException.new(item.errors.full_messages.join(", "))]
      end
    end
  end

  def self.update_task(task_id:, title: nil, description: nil, status: nil)
    item = find(task_id: task_id, table_name: "TASK")
    if item
      now = Time.now
      item.title = title unless title.nil?
      item.description = description unless description.nil?
      item.status = status unless status.nil?
      item.updated_at = now
      if item.save
        [item, nil]
      else
        if item.valid? # server error
          puts "[ERROR] Unknown issue trying to update valid item #{item.to_h} on app table."
          [nil, ServerError.new]
        else # validation error
          [nil, InvalidInputException.new(item.errors.full_messages.join(", "))]
        end
      end
    else
      [nil, TaskNotFoundException.new(task_id)]
    end
  end

  def self.list_tasks(next_token:,max_items:)
    # Add Pagination Traits
    qbuilder = build_query.on_index(:reverse).
      key_expr(":table_name = ?", "TASK").
      scan_ascending(false).
      limit(max_items)
    if next_token
      esk = PaginationToken.unwrap(next_token)
      if esk.nil?
        return [
          nil,
          InvalidInputException.new("Invalid or expired pagination token.")
        ]
      end
      qbuilder.exclusive_start_key(esk)
    end
    query = qbuilder.complete!
    results = query.page
    next_token = nil
    if lek = query.last_evaluated_key
      next_token = PaginationToken.generate(lek)
      if next_token.nil?
        puts "[ERROR] Unable to generate pagination token from last evaluated key #{lek.to_json}"
        return [
          nil,
          ServerError.new
        ]
      end
    end
    return [
      {
        tasks: results,
        next_token: next_token
      },
      nil
    ]
  end
end
