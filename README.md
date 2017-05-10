# Online Trials AWS Architecture

## Current Manual steps required:

- Manually deleting the stack (via the console or cli) will leave the usage plan behind, this will need deleting.
- If the stack has just been built for testing, update the R53 entry currently in the correct AWS account (request{stage}.trial.alfresco.com) to point to the cloudfront distribution address. This entry is found in the Outputs list in the CloudFormation dashboard.
- The SSH key required for the OpsWorksGitSSHKey is in our password management system. Get the file from the "Private key (csv)" entry and either paste it into the correct parameter when building a new stack or updating the SSH key setting under the correct OpsWorks stack.

## DR Steps in case of catastrophe:

- Lambdas that are used for these templates can currently be found here: https://github.com/Alfresco/devops-lambdas
- Check which Lambda packages we need by referring to the control template and stack template. Upload these to a bucket thats in the same region as the DR system and when deploying the DR stack. We keep two buckets one for test and one for prod. Make sure the prod bucket only contains zip files from the master branch.
- ### The Lambdas MUST be deployed first as the control system template will not deploy without knowing where the packages lambdas are.
- Find the correct R53 entry in the correct AWS account (either test or prod) and update the alias to the new cloudfront distribution address. This entry is found in the Outputs list in the CloudFormation dashboard. This will be automated in V2.0.x
- If necessary, find the correct Trial AMI and share it to another region/account. Update the parameter in the online-trial-stack.yaml template.
- As the VPC and security groups used by Trials arent created by the control, they will need recreating manually in another region/account (chosen for DR).

For a comprehensive documentation on the Online Trials Architecture , please visit our [Wiki](https://github.com/Alfresco/online-trials-architecture/wiki)

## License and Author
Copyright 2017, Alfresco

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
