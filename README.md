# Online Trials AWS Architecture

## API build testing
To test that the API built as expected:

- Get the "OnlineTrialsRequestEndPoint" URI from the Outputs section of the CloudFormation Dashboard.
- Using the AWS Dashboard of the account the stack is deployed in goto API Gateway -> API Keys -> Select the API Key that was just created, then click on "Show" to reveal the key.
- Then using either cURL/PostMan/Some other Rest client, configure a GET request using the above URI and the API key. Set a header with the key "x-api-key" and the value of the api key. You should then receive a successful response.