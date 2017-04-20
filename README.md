# Online Trials AWS Architecture

## Current Manual steps required:

- Manually deleting the stack (via the console or cli) will leave the usage plan behind, this will need deleting.
- If the stack has just been built for testing, update the R53 entry currently in the SYSTEMS account (request{stage}.trial.alfresco.com) to point to the cloudfront distribution address. This entry is found in the Outputs list in the CloudFormation dashboard.
- The SSH key required for the OpsWorksGitSSHKey is in our password management system under AWS -> Online Trials. Get the file from the "Private key (csv)" entry and either paste it into the correct parameter when building a new stack or updating the SSH key setting under the correct OpsWorks stack.

## DR Steps in case of catastrophe:

- Lambdas that are used for these templates can currently be found here: https://git.alfresco.com/alfresco_devops/devops-lambdas
- Check which Lambda packages we need by referring to the control template and stack template. Upload these to a bucket thats in the same region as the DR system and when deploying the DR stack, update the parameters for "LambdaBucket" to that bucket name. This will be automated in V2.0.x
- Find the correct R53 entry in the SYSTEMS account (either test or prod) and update the alias to the new cloudfront distribution address. This entry is found in the Outputs list in the CloudFormation dashboard. This will be automated in V2.0.x
- If necessary, find the correct Trial AMI and share it to another region/account. Update the parameter in the online-trial-stack.yaml template.
- As the VPC and security groups used by Trials arent created by the control, they will need recreating manually in another region/account (chosen for DR).
