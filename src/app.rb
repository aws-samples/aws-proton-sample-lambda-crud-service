# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

require_relative 'shapes'
require_relative 'task'
require 'time'

class App
  class << self
    def list_tasks(input)
      result, error = Task.list_tasks(next_token: input.next_token, max_items: input.max_items)
      if error.nil?
        tasks = result[:tasks]
        next_token = result[:next_token]
        [ListTasksOutput.new(tasks: tasks, next_token: next_token), nil]
      else
        [nil, error]
      end
    end

    def create_task(input)
      result, error = Task.create_task(
        title: input.title,
        description: input.description,
        status: input.status
      )
      if error.nil?
        [CreateTaskOutput.new(task: result), nil]
      else
        [nil, error]
      end
    end

    def update_task(input)
      result, error = Task.update_task(
        task_id: input.task_id,
        title: input.title,
        description: input.description,
        status: input.status
      )
      if error.nil?
        [UpdateTaskOutput.new(task: result), nil]
      else
        [nil, error]
      end
    end

    def get_task(input)
      result, error = Task.get_task(
        task_id: input.task_id
      )
      if error.nil?
        [GetTaskOutput.new(task: result), nil]
      else
        [nil, error]
      end
    end

    def delete_task(input)
      _, error = Task.delete_task(
        task_id: input.task_id
      )
      if error.nil?
        [nil, nil]
      else
        [nil, error]
      end
    end
  end
end
