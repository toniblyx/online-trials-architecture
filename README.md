# Online Trials AWS Architecture

## API build testing
To test that the API built as expected:

- Get the "OnlineTrialsTestEndPoint" URI from the Outputs section of the CloudFormation Dashboard.
- Using the AWS Dashboard of the account the stack is deployed in goto API Gateway -> API Keys -> Select the API Key that was just created, then click on "Show" to reveal the key.
- Then using either cURL/PostMan/Some other Rest client, configure a GET request using the above URI and the API key. Set a header with the key "x-api-key" and the value of the api key. You should then receive a successful response (200).

# Current Manual steps required:

- Manually deleting the stack (via the console or cli) will leave the usage plan behind, this will need deleting.
- If the stack has just been built for testing, update the R53 entry currently in the SYSTEMS account (request{stage}.trial.alfresco.com) to point to the cloudfront distribution address. This entry is found in the Outputs list in the CloudFormation dashboard.
- The SSH key required for the OpsWorksGitSSHKey is in our password management system under AWS -> Online Trials. Get the file from the "Private key (csv)" entry and either paste it into the correct parameter when building a new stack or updating the SSH key setting under the correct OpsWorks stack.

# DR Steps in case of catastrophe:

- Pre packaged Lambdas can currently be found here: https://gitlab.alfresco.com/paas/devops-lambdas
- We use the prepacked EmptyBucketsLambda.zip and ApiDomainName.zip lambdas. Upload thess to a bucket thats in the same region as the DR system and when deploying the DR stack, update the parameters for "LambdaBucket" to that bucket name. This will be automated in V2.0.
- Find the correct R53 entry in the SYSTEMS account (either test or prod) and update the alias to the new cloudfront distribution address. This entry is found in the Outputs list in the CloudFormation dashboard. This will be automated in V2.0.
- If necessary, find the correct Trial AMI and share it to another region/account. Update the parameter in the online-trial-stack.yaml template.
- As the VPC and security groups used by Trials arent created by the control, they will need recreating manually in another region/account and the online-trial-stack.yaml template will need its parameters updated for this.
