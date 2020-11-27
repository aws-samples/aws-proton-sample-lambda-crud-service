# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

require 'spec_helper'

describe App do
  let(:stub_client) do
    stub_client = Aws::DynamoDB::Client.new(stub_responses: true)
    Task.configure_client(client: stub_client)
    stub_client
  end

  describe "ListTask" do
    it 'successfully returns a basic response' do
      test_time = Time.now
      stub_client.stub_responses(:query,
        {
          items: [
            {
              "hk" => "test-uuid",
              "rk" => "TASK",
              "title" => "Test Task",
              "description" => "Desc",
              "status" => "TODO",
              "created_at" => test_time.to_i,
              "updated_at" => test_time.to_i
            }
          ],
          last_evaluated_key: nil
        }
      )
      input = ListTasksInput.new({})
      output, error = App.list_tasks(input)
      expect(error).to be_nil
      expect(output.next_token).to be_nil
      expect(output.tasks.size).to eq(1)
      expect(output.tasks.first.task_id).to eq("test-uuid")
    end
  end

  describe "CreateTask" do
    it 'creates a task object successfully' do
      input = CreateTaskInput.new({
        "body" => Base64.encode64({
          'title' => "Test",
          'description' => "Created Task",
          'status' => "DONE"
        }.to_json),
        "isBase64Encoded" => true
      })
      output, error = App.create_task(input)
      expect(output.task.task_id).to be_a(String)
      expect(output.task.title).to eq("Test")
      expect(error).to be_nil
    end

    it 'validates required params' do
      invalid_inputs = [
        CreateTaskInput.new({
          "body" => {
            'description' => "Created Task",
            'status' => "DONE"
          }.to_json
        }),
        CreateTaskInput.new({
          "body" => {
            'title' => "Test",
            'status' => "DONE"
          }.to_json,
          "isBase64Encoded" => true
        }),
        CreateTaskInput.new({
          "body" => {
            'title' => "Test",
            'description' => "Created Task",
          }.to_json
        }),
        CreateTaskInput.new({
          "body" => {}.to_json
        })
      ]
      invalid_inputs.each do |input|
        output, error = App.create_task(input)
        expect(output).to be_nil
        expect(error).to be_a(InvalidInputException)
      end
    end
  end

  describe 'GetTask' do
    it 'retrieves a task successfully' do
      test_time = Time.now
      stub_client.stub_responses(:get_item,
        {
          item: {
            "hk" => "test-uuid",
            "rk" => "TASK",
            "title" => "Test Task",
            "description" => "Desc",
            "status" => "TODO",
            "created_at" => test_time.to_i,
            "updated_at" => test_time.to_i
          }
        }
      )
      input = GetTaskInput.new({
        "pathParameters" => {
          "id" => "test-uuid"
        }
      })
      output, error = App.get_task(input)
      expect(stub_client.api_requests.size).to eq(1)

      request = stub_client.api_requests.first
      expect(request[:params]).to eq({
        key: {
          "hk" => {s: "test-uuid"},
          "rk" => {s: "TASK"}
        },
        table_name: "Task"
      })

      expect(error).to be_nil
      expect(output.task.task_id).to eq("test-uuid")
    end

    it 'raises an error when a task does not exist' do
      stub_client.stub_responses(:get_item, {
        item: nil
      })
      input = GetTaskInput.new({
        "pathParameters" => {
          "id" => "test-uuid"
        }
      })
      output, error = App.get_task(input)
      expect(stub_client.api_requests.size).to eq(1)

      request = stub_client.api_requests.first
      expect(request[:params]).to eq({
        key: {
          "hk" => {s: "test-uuid"},
          "rk" => {s: "TASK"}
        },
        table_name: "Task"
      })

      expect(output).to be_nil
      expect(error).to be_a(TaskNotFoundException)
    end
  end

  describe 'UpdateTask' do
    it 'updates a task successfully' do
      test_time = Time.now
      stub_client.stub_responses(
        :get_item,
        {
          item: {
            "hk" => "test-uuid",
            "rk" => "TASK",
            "title" => "Test Task",
            "description" => "Desc",
            "status" => "TODO",
            "created_at" => test_time.to_i,
            "updated_at" => test_time.to_i
          }
        }
      )
      stub_client.stub_responses(
        :update_item,
        {
          attributes: {
            "hk" => "test-uuid",
            "rk" => "TASK",
            "title" => "Test Task",
            "description" => "Desc",
            "status" => "DONE",
            "created_at" => test_time.to_i,
            "updated_at" => test_time.to_i
          }
        }
      )
      input = UpdateTaskInput.new({
        "pathParameters" => {
          "id" => "test-uuid"
        },
        "body" => {
          "status" => "DONE"
        }.to_json
      })
      output, error = App.update_task(input)

      expect(error).to be_nil
      expect(stub_client.api_requests.size).to eq(2)

      get_request = stub_client.api_requests[0]
      expect(get_request[:params]).to eq({
        key: {
          "hk" => {s: "test-uuid"},
          "rk" => {s: "TASK"}
        },
        table_name: "Task"
      })

      expect(output.task.status).to eq("DONE")
    end

    it 'raises an error when a task does not exist' do
      stub_client.stub_responses(:get_item, {
        item: nil
      })
      input = UpdateTaskInput.new({
        "pathParameters" => {
          "id" => "test-uuid"
        },
        "body" => {
          "status" => "DONE"
        }.to_json
      })
      output, error = App.update_task(input)
      expect(stub_client.api_requests.size).to eq(1)

      request = stub_client.api_requests.first
      expect(request[:params]).to eq({
        key: {
          "hk" => {s: "test-uuid"},
          "rk" => {s: "TASK"}
        },
        table_name: "Task"
      })

      expect(output).to be_nil
      expect(error).to be_a(TaskNotFoundException)
    end
  end

  describe 'DeleteTask' do
    it 'deletes a task successfully' do
      test_time = Time.now
      stub_client.stub_responses(:get_item,
        {
          item: {
            "hk" => "test-uuid",
            "rk" => "TASK",
            "title" => "Test Task",
            "description" => "Desc",
            "status" => "TODO",
            "created_at" => test_time.to_i,
            "updated_at" => test_time.to_i
          }
        }
      )
      input = DeleteTaskInput.new({
        "pathParameters" => {
          "id" => "test-uuid"
        }
      })
      output, error = App.delete_task(input)

      expect(error).to be_nil

      expect(stub_client.api_requests.size).to eq(2)
      # Get and Delete have same params
      stub_client.api_requests.each do |request|
        expect(request[:params]).to eq({
          key: {
            "hk" => {s: "test-uuid"},
            "rk" => {s: "TASK"}
          },
          table_name: "Task"
        })
      end

      expect(output).to be_nil
    end

    it 'raises an error when a task does not exist' do
      stub_client.stub_responses(:get_item, {
        item: nil
      })
      input = DeleteTaskInput.new({
        "pathParameters" => {
          "id" => "test-uuid"
        }
      })
      output, error = App.delete_task(input)
      expect(stub_client.api_requests.size).to eq(1)

      request = stub_client.api_requests.first
      expect(request[:params]).to eq({
        key: {
          "hk" => {s: "test-uuid"},
          "rk" => {s: "TASK"}
        },
        table_name: "Task"
      })

      expect(output).to be_nil
      expect(error).to be_a(TaskNotFoundException)
    end
  end
end
