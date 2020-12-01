# AWS Proton Sample Lambda CRUD API Service

This sample application contains AWS Lambda function code to handle a CRUD API endpoint. This sample can be deployed with AWS Proton using the sample [Lambda CRUD API Service](https://github.com/aws-samples/aws-proton-sample-templates/tree/main/lambda-crud-svc) environment and service templates.

With the sample Proton templates, you can provide a simple `noun` for the API like `tasks`, and Proton will create the Create, Read, Update and Delete Lambda functions. The handlers will be of the form `get_{noun}`, `create_{noun}`, `list_{noun}`, `update_{noun}`, `delete_{noun}`.  The default noun is `task`.

## Testing

Run unit tests with the `rspec` command or `make test`.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
