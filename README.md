# AWS Proton Sample Lambda CRUD Service

This app contains the lambdas which handle the CRUD APIs for `tasks`. The infrastructure is provisioned by AWS Proton. The infrastructure for this service is managed by the AWS Proton [lambda CRUD service](https://github.com/aws-samples/aws-proton-sample-templates/tree/main/lambda-crud-svc).

Customers can provide a simple `noun` and Proton will create the Create, Read, Update and Destroy lambda functions. The handlers will be of the form `get_{noun}`, `create_{noun}`, `list_{noun}`, `update_{noun}`, `delete_{noun}`. 

In this sample, our lambdas are written to handle the `task` noun. 

## Testing

Run unit tests with the `rspec` command or `make test`.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

