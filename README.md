# Checkout App

This is a simple web app using the Vue bootstrapper which makes a request to a Node.js Express backend to get a couple of variables.

A version of this repo is running at:

<https://interview.checkout.josh-simpson.me>

## Local development

To run both the frontend and back end locally, you need to have [Docker](https://docs.docker.com/get-docker/) installed, and be able to run docker-compose. You can verify if you have the pre-requisites by running:

```bash
docker-compose -v
```

If the above returns a docker-compose version, then you this by running the following command in the root directory:

```bash
docker-compose up
```

This will spin up two hot-reloading docker containers. You can edit code in `frontend/` and `backend` and both containers will attempt to update the running application with your changes.

## Deployment - Infrastructure

The infrastructure is deployed with Terraform.

### Deployment - Infrastructure - Prerequisites

This Terraform script works with version `0.12.29` - the easiest way to make sure you've got this running is:

- Install [tfenv (a Terraform Version Manager)](https://github.com/tfutils/tfenv)
- `tfenv install 0.12.29`
- `tfenv use 0.12.29`

Once you have the right Terraform version installed, you will need to modify  `terraform/variables.tf` with the values that suit the implementation you want:

```terraform
variable "region" {
  default = "eu-west-1"
  type = string
  description = "The AWS region that you want to host your application in"
}

variable "domain" {
  default = "checkout.josh-simpson.me"
  type = "string"
  description = "The domain name for a domain you have in Route53"
}

variable "api-subdomain" {
  default = "api"
  type = "string"
  description = "The subdomain you want to host your API at"
}

variable "cluster_name" {
  default = "checkout-app"
  type = string
  description = "The name you want for the cluster that your service will live in"
}

variable "service_name" {
  default = "api"
  type = string
  description = "The name of your backend service"
}
```

This application assumes that a hosted zone already exists to deploy this application into. If not, then you'll need to:

⚠️ If you are unfamiliar with DNS, grab somebody for help before making the following changes!

- Manually create a Hosted Zone in AWS for the domain / subdomain that you want to use
- Use the 4 values in the NS record from the new Hosted Zone to provide 4 new NS records for the relevant domain in your current registrar.

You will also need to make sure you have your AWS credentials configured. This can be done through various means (awsume, aws-vault, saml2aws), but we will assume that you have a way to log in as a user with the correct credentials and permissions to deploy.

### Initial Deployment - Infrastructure

Providing everything is now configured, you should be able to run:

```bash
cd terraform
terraform apply
```

Examine the changes, and make sure that it looks right for you. If something looks off, make sure to ask somebody else to look over it with you!

If everything looks fine, type `yes` and hit enter.

This *should* take a few minutes to deploy, but may take a lot longer if CloudFront is feeling unkind that day. Keep an eye on your terraform logs, and if it's just Cloudfront that appears to be taking a while, just let it run. Go grab a coffee!

### Initial Deployment - Applications - Frontend

Once the infrastructure is up, you'll have an empty S3 bucket. Let's get that filled:

```bash
cd frontend
./build-and-deploy.sh -t <S3-BUCKET-URL> -c <CLOUDFRONT-DISTRIBUTION-ID>
```

- `<S3-BUCKET-URL>` - Should be replaced with the URL for the S3 bucket that was created in Terraform. This should look something like:
  
  `<ENVIRONMENT>.<DOMAIN>`

  So using the `variables.tf` that we have in this example, the bucket would be:

  `interview.checkout.josh-simpson.me`

  You should be able to find this bucket in S3 through the AWS Console and just copy that address though
- `<CLOUDFRONT-DISTRIBUTION-ID>` - Should be replaced with the Cloudfront Distribution ID. You should be able to find this through the AWS Console too. Head to the Cloudfront section in AWS, and find the row with the same `origin` as your S3 bucket is named. Copy the ID from that field and use that here

This command will lint check your code first (and cancel the deploy if it finds something wrong), and then build and deploy the code and invalidate the Cloudfront cache if everything seems correct.

### Initial Deployment - Applications - Backend

Once you've run the Terraform script, ECS will begin trying to pull code from the ECR repository created. Until it has an image that it can run, it will keep trying and failing. Let's give it something to work with:

- Head to AWS ECS in the AWS console and select 'Repositories' under Amazon ECR
- Select the repository that was created in Terraform (should have the same name set by `service_name` in `terraform/variables.tf`)
- Click the push commands
- `cd backend`
- Follow the instructions provided by the Push Commands dialogue

If your application is capable of running, this should get picked up by ECS within the next minute or so. To check this, click 'Clusters' and you should see the earlier created cluster with a non-zero number above 'Running tasks'

## Future app deployment

### Frontend

The frontend can be deployed using the bash script described in the initial deployment stage.

### Backend

Whilst the current `deploy-ecs.sh` script does not work (thanks IAM), a new version can be uploaded by:

- Pushing a new version to ECR (follow the initial deployment instructions but in the `tag` step, replace `latest` with a new version number)

- modifying `terraform/backend/task-definitions/api.json.tpl`, and changing the image from:

  `"image": "${image}:latest"`

  to

  `"image": "${image}:<VERSION>"`

  Where `<VERSION>` is the version you pushed.

- `terraform apply`

⚠ This step requires enough resources to be available for both versions to exist at the same time, as ECS tries to gracefully deploy a new app and make sure it's healthy, before routing traffic to it and finally discarding the old version. Currently this requires twice as many EC2 instances as it does applications running for a successful deploy - see next section for more info.

## Scaling

### Scaling - Frontend

The frontend is based in an S3 bucket, served via Cloudfront, so should not require any modifications to scale from a performance perspective.

### Scaling - Backend

At the moment, the scaling is manual, happening across two values in `terraform/main.tf`:

- desired_instances - This is the number of servers that are running - this determines how many resources are available for containers of our actual application to run on. Because we are running the smallest instances (servers), we have very limited resources per server.

  This means that if this value is small then the number of our containers running will also be small.

- desired_containers - This is the number of containers of our application running. These containers can only run if there are enough 'resources' available to them on a server, but so long as there are, it will create the number of desired containers.

Both of the above figures can be modified in `main.tf`.

If you want to deploy a new version of the application (container), then you will need to make sure that the `desired_instances` is double the value of `desired_containers` so that ECS has resources it can use to deploy the application whilst keeping the previous version alive (incase anything is wrong with the new version).

Once it has deployed it, you can return `desired_instances` to the same level as `desired_containers`.

## Network Diagram

![An image representing a base version of the architecture](./docs/arch-diagram.png)

## To be added/improved

- Auto scaling policies for EC2 and ECS services
- Deployment script for ECS
- Example pipeline scripts for frontend and backend (Jenkins, Github Actions, CircleCI)
- Better response to new version being deployed as a zero-downtime deployment, where EC2 instances do not have the resources to support a deploy

## Short-term decision log

- 2021/03/13 - Josh - Keep EC2 containers at t2.micro to save money on resources
- 2021/03/13 - Josh - Leave in IAM modifications for potential discussion later on
- 2021/03/13 - Josh - Leave the deployment script for the backend until IAM issues are resolved. It was a long and bitter fight, and I accept defeat.
- 2021/03/06 - Josh - Use ECS instead of Serverless / Lambda functions as this is more contextually relevant to the environment that is being deployed into
