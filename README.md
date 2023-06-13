# CLI Docker Automation
CLI Docker Automation is a repository that contains a collection of scripts and configuration files to automate the process of setting up and managing AWS resources, specifically for handling gaming updates through CLI commands. This repository is designed to provide a simple, automated, and robust template for creating and managing a VPC, CodeCommit repository, CodePipeline, CodeBuild project, and their respective IAM roles and policies, which are essential for automating gaming updates via CLI commands.

## Features
* Terraform scripts for creating and configuring AWS resources including:
  * VPC
  * CodeCommit repository
  * CodePipeline
  * CodeBuild project
  * IAM roles and policies.
* Customizable configuration files to adapt to different use cases or environments.
* Simplified CLI for initiating and monitoring gaming updates.
## Prerequisites
* AWS account with sufficient permissions to create and manage the mentioned AWS resources.
* AWS CLI configured with appropriate credentials.
* Docker installed on your local machine.
* Basic knowledge of Terraform, AWS services, and CLI commands.
## Getting Started
1. Clone the repository
    ```bash
    git clone https://github.com/semperfitodd/cli_docker_automation.git
    cd cli_docker_automation
    ```
2. Configure AWS CLI

    Make sure that you have the AWS CLI configured with the appropriate credentials. You can configure it by running:
    ```bash
    aws configure
    ```
3. Update variables in variables.tf and buildspec.yml
   ```yaml
    env:
      variables:
        ENVIRONMENT: "cli-docker-automation"
        TEST_FILES_DIR: "/test_files"
    ```
4. Run Terraform to set up AWS resources
    Run the setup script to create and configure the necessary AWS resources (VPC, CodeCommit repository, CodePipeline, CodeBuild project, IAM roles and policies):
    ```bash
    cd terraform
    terraform init
    terraform plan -out=plan.out
    terraform apply plan.out
    ```
    Note: You may need to customize variables in the setup script to match your requirements.
5. Follow along with AWS Codebuild
    * Navigate to AWS Codebuild
   
   ![codebuild.png](images%2Fcodebuild.png)
    * Select 'Tail Logs'
   
   ![tail_logs.png](images%2Ftail_logs.png)
    * Success
   
   ![codebuild_success.png](images%2Fcodebuild_success.png)
6. Confirm in S3

   ![s3.png](images%2Fs3.png)