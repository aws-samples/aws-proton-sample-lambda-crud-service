# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

class ApiGatewayException
  attr_reader :status_code

  def body
    {
      exception: @exception,
      message: @message
    }.to_json + "\n"
  end
end

class InvalidInputException < ApiGatewayException
  def initialize(msg)
    @status_code = 400
    @exception = "InvalidInputException"
    @message = msg
  end
end

class ServerError < ApiGatewayException
  def initialize(msg = "Unknown error.")
    @status_code = 500
    @exception = "ServerError"
    @message = msg
  end
end

class TaskNotFoundException < ApiGatewayException
  def initialize(task_id)
    @status_code = 404
    @exception = "TaskNotFoundException"
    @message = "Task with ID #{task_id} not found."
  end
end
