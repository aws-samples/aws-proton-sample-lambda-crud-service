# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

require 'base64'

class DeleteTaskInput
  attr_reader :task_id

  def initialize(event_json)
    @task_id = event_json["pathParameters"]["id"]
  end

  def valid?
    true
  end

  def error
    nil
  end
end

class GetTaskInput
  attr_reader :task_id

  def initialize(event_json)
    @task_id = event_json["pathParameters"]["id"]
  end

  def valid?
    true
  end

  def error
    nil
  end
end

class GetTaskOutput
  attr_reader :task

  def initialize(task:)
    @task = task
  end

  def to_output
    { task: @task }.to_json + "\n"
  end
end

class UpdateTaskInput
  attr_reader :task_id, :title, :description, :status

  def initialize(event_json)
    @task_id = event_json["pathParameters"]["id"]
    body = event_json["body"]
    if event_json["isBase64Encoded"]
      body = Base64.decode64(body)
      puts "[DEBUG] Decoded #{body} from base64 encoded body #{event_json["body"]}"
    end
    if body.nil?
      @errors = ["Request body must be present."]
    else
      begin
        body_json = JSON.parse(body)
        @errors = []
        @title = body_json["title"]
        @description = body_json["description"]
        @status = body_json["status"]
      rescue JSON::ParserError
        @errors = ["Request body must be valid JSON."]
      end
    end
  end

  def valid?
    if @title.nil? && @description.nil? && @status.nil?
      @errors << "Must include at least one of 'title', 'description', or 'status' parameters."
      false
    else
      true
    end
  end

  def error
    if @errors.empty?
      nil
    else
      InvalidInputException.new(@errors.join(" "))
    end
  end
end

class UpdateTaskOutput
  attr_reader :task

  def initialize(task:)
    @task = task
  end

  def to_output
    { task: @task }.to_json + "\n"
  end
end

class CreateTaskInput
  attr_reader :title, :description, :status

  def initialize(event_json)
    body = event_json["body"]
    if event_json["isBase64Encoded"]
      body = Base64.decode64(body)
      puts "[DEBUG] Decoded #{body} from base64 encoded body #{event_json["body"]}"
    end
    begin
      body_json = JSON.parse(body)
      @errors = []
      @title = body_json["title"]
      @description = body_json["description"]
      @status = body_json["status"]
    rescue JSON::ParserError
      @errors = ["Request body must be valid JSON."]
    end
  end

  def valid?
    valid = true
    if @title.nil?
      @errors << "Missing 'title' parameter."
      valid = false
    end
    if @description.nil?
      @errors << "Missing 'description' parameter."
      valid = false
    end
    if @status.nil?
      @errors << "Missing 'status' parameter."
      valid = false
    end
    valid
  end

  def error
    if @errors.empty?
      nil
    else
      InvalidInputException.new(@errors.join(" "))
    end
  end
end

class CreateTaskOutput
  attr_reader :task

  def initialize(task:)
    @task = task
  end

  def to_output
    { task: @task }.to_json + "\n"
  end
end

class ListTasksInput
  attr_reader :next_token, :max_items

  def initialize(event_json)
    qsp = event_json.fetch("queryStringParameters", {})
    @next_token = qsp["next_token"]
    @max_items = 25
    @errors = []
    if mi = qsp["max_items"]
      begin
        @max_items = Integer(mi)
      rescue ArgumentError
        @errors << "Invalid value #{mi} for max_items parameter."
      end
    end
  end

  def valid?
    if !@errors.empty?
      false
    elsif @max_items > 25
      @errors << "Max item count of #{@max_items} exceeds valid maximum of 25."
      false
    else
      true
    end
  end

  def error
    if @errors.empty?
      nil
    else
      InvalidInputException.new(@errors.join(" "))
    end
  end
end

class ListTasksOutput
  attr_reader :tasks, :next_token

  def initialize(tasks:, next_token: nil)
    @tasks = tasks
    @next_token = next_token
  end

  def to_output
    ret = {
      tasks: @tasks,
      next_token: @next_token
    }

    ret.to_json + "\n"
  end
end
