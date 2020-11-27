# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

require_relative 'app'
require_relative 'errors'
require_relative 'shapes'
require 'aws-xray-sdk/lambda'

def list_task(event:,context:)
  begin
    input = ListTasksInput.new(event)
    unless input.valid?
      error = input.error
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
    output, error = App.list_tasks(input)
    if error.nil?
      return {
        statusCode: 200,
        body: output.to_output
      }
    else
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
  rescue StandardError => e
    puts "[FATAL] Uncaught exception #{e}\n#{e.backtrace}\n"
    err = ServerError.new
    return {
      statusCode: err.status_code,
      body: err.body
    }
  end
end

def create_task(event:,context:)
  begin
    input = CreateTaskInput.new(event)
    unless input.valid?
      error = input.error
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
    output, error = App.create_task(input)
    if error.nil?
      return {
        statusCode: 200,
        body: output.to_output
      }
    else
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
  rescue StandardError => e
    puts "[FATAL] Uncaught exception #{e}\n#{e.backtrace}\n"
    err = ServerError.new
    return {
      statusCode: err.status_code,
      body: err.body
    }
  end
end

def get_task(event:,context:)
  begin
    input = GetTaskInput.new(event)
    unless input.valid?
      error = input.error
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
    output, error = App.get_task(input)
    if error.nil?
      return {
        statusCode: 200,
        body: output.to_output
      }
    else
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
  rescue StandardError => e
    puts "[FATAL] Uncaught exception #{e}\n#{e.backtrace}\n"
    err = ServerError.new
    return {
      statusCode: err.status_code,
      body: err.body
    }
  end
end

def delete_task(event:,context:)
  begin
    input = DeleteTaskInput.new(event)
    unless input.valid?
      error = input.error
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
    _, error = App.delete_task(input)
    if error.nil?
      return {
        statusCode: 204
      }
    else
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
  rescue StandardError => e
    puts "[FATAL] Uncaught exception #{e}\n#{e.backtrace}\n"
    err = ServerError.new
    return {
      statusCode: err.status_code,
      body: err.body
    }
  end
end

def update_task(event:,context:)
  begin
    input = UpdateTaskInput.new(event)
    unless input.valid?
      error = input.error
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
    output, error = App.update_task(input)
    if error.nil?
      return {
        statusCode: 200,
        body: output.to_output
      }
    else
      return {
        statusCode: error.status_code,
        body: error.body
      }
    end
  rescue StandardError => e
    puts "[FATAL] Uncaught exception #{e}\n#{e.backtrace}\n"
    err = ServerError.new
    return {
      statusCode: err.status_code,
      body: err.body
    }
  end
end
