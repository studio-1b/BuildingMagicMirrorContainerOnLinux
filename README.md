# BuildingMagicMirrorContainerOnLinux
Container for serveronly instance of MagicMirror.  Bash scripts to automate entire process and Dockerfile for container build instruction.  Script has notes to upload docker image to AWS public ECR.

## To download these scripts

```bash
git clone https://github.com/studio-1b/BuildingMagicMirrorContainerOnLinux.git
```

## To create the docker image, and run in background, just run

The shell script automates instructions to build a MagicMirror server-only instance.  The Dockerfile has instruction to download MagicMirror software from github

```bash
./install_magicmirror.sh
```

## To build the docker image, don't run it, BUT push the image to docker repository

use a text editor and goto the last lines of the file, and change the 1)tag AND 2)push commands to YOUR repository for a container image.
it currently pushes to my public ECR container repository.  And you don't have a password for it.  So, if you start a AWS account, you can create your own ECR public repository, and password with permissions to upload.

This has some guidance on creating ECR repository:
https://blog.tericcabrel.com/push-docker-image-aws-elastic-container-registry/

Most instructions don't have enough data about the step ..."Retrieve an authentication token and authenticate your Docker client to your registry...".  This means you goto your AWS account, upper-right-corner is [Your name], open that menu, click "security credentials"
Goto the menu on left side "Users".  Click button "create user".  Give name like "publicecr".  Finish creating user.
After user is created, click into user "publicecr" or whatever you named it.  
1) security credentials tab.  Create Access Key.  You need this and the secret key, to when you run "aws configure".
2) permissions tab.  You need to add permission for ECR-public.  The permission is in a JSON format below.
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr-public:CompleteLayerUpload",
                "ecr-public:GetAuthorizationToken",
                "ecr-public:UploadLayerPart",
                "ecr-public:InitiateLayerUpload",
                "ecr-public:BatchCheckLayerAvailability",
                "ecr-public:PutImage",
                "sts:GetServiceBearerToken"
            ],
            "Resource": "*"
        }
    ]
}
Then you need to run "aws configure"

Then after all that is done, run:

```bash
./install_magicmirror.sh pushonly
```
