# Online Trials AWS Architecture

## API build testing
To test that the API built as expected:

- Get the "OnlineTrialsTestEndPoint" URI from the Outputs section of the CloudFormation Dashboard.
- Using the AWS Dashboard of the account the stack is deployed in goto API Gateway -> API Keys -> Select the API Key that was just created, then click on "Show" to reveal the key.
- Then using either cURL/PostMan/Some other Rest client, configure a GET request using the above URI and the API key. Set a header with the key "x-api-key" and the value of the api key. You should then receive a successful response (200).

# Current Manual steps required:

- Once this stack is deployed, you must associate the created api key with the usage plan.
- Manually deleting the stack (via the console or cli) will leave the usage plan behind, this will need deleting.
- If the stack has just been built for testing, update the R53 entry currently in the SYSTEMS account (request{stage}.trial.alfresco.com) to point to the cloudfront distribution address. This entry is found in the Outputs list in the CloudFormation dashboard.

# DR Steps in case of catastrophe:

- Pre packaged Lambdas can currently be found here: https://gitlab.alfresco.com/paas/devops-lambdas
- We use the prepacked EmptyBucketsLambda.zip and ApiDomainName.zip lambdas. Upload thess to a bucket thats in the same region as the DR system and when deploying the DR stack, update the parameters for "LambdaBucket" to that bucket name. This will be automated in V2.0.
- Find the correct R53 entry in the SYSTEMS account (either test or prod) and update the alias to the new cloudfront distribution address. This entry is found in the Outputs list in the CloudFormation dashboard. This will be automated in V2.0.
