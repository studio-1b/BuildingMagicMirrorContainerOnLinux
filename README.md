# BuildingMagicMirrorContainerOnLinux
Container for serveronly instance of MagicMirror.  Bash scripts to automate entire process and Dockerfile for container build instruction.  Script has notes to upload docker image to AWS public ECR.

- MagicMirror is a opensource project built in Nodejs platform, to provide a dashboard rendered by a javascript renderer named Electron.  But it has a serveronly mode, that works well as webserver.
. [https://github.com/MagicMirrorOrg/MagicMirror](https://github.com/MagicMirrorOrg/MagicMirror)
- AWS is Amazon's Cloud Services platform
- ECR is AWS's docker container image repository
- There are 2 kinds of repositories: private and public, henceforth referred to as ECR and ECR-public
- private ECR repositories, you need credentials to download and upload.  
- Public ECR repositories, you only need credentials to upload.  Anyone can download from Internet
- AWS ECR does have a cost, but a generous free tier [https://aws.amazon.com/ecr/pricing/](https://aws.amazon.com/ecr/pricing/).

## To download these scripts

```bash
git clone https://github.com/studio-1b/BuildingMagicMirrorContainerOnLinux.git
```

## To create the docker image, and run in background, just run

The shell script automates instructions to build a MagicMirror server-only instance.  The Dockerfile has instruction to download MagicMirror software from github.  Then creates a container image, and runs it in background.

```bash
./install_magicmirror.sh
```

After it is finished, the magic mirror software should be running in server-only mode.  Goto your internet browser and visit:
```
http://localhost:3000/
```
b/c I changed to "config/config.js" to listen on port 3000.  Same one you downloaded from github.  The Dockerfile just instructs docker to overwrite the default file downloaded from MagicMirror github, with the one with my permission changes and port changes.


## To build the docker image, don't run it, BUT push the image to docker repository

>[!WARNING]
> You need to have your own AWS account, and create your own AWS ECR public repository, before you make the changes below

Use a text editor and goto the last lines of the file "install_magicmirror.sh", and change the 1)image tag AND 2)push commands to YOUR repository for a container image.

<pre>
if [ "$1" == "pushonly" ]; then
  aws ecr-public get-login-password --region <b><i>&lt;your AWS region>&gt;</i></b> | docker login --username AWS --password-stdin <b><i>&lt;this was my public repo URL, with a MagicMirror container image&gt;</i></b>
  docker tag mm_serveronly:latest <b><i>&lt;this was my public repo URL, with a MagicMirror container image&gt;</i></b>
  docker push <b><i>&lt;this was my public repo URL, with a MagicMirror container image&gt;</i></b>
  if [ $? -eq 0 ]; then
    echo "pushed to public ECR repository"
fi
</pre>

It currently pushes to my public ECR container repository.  And you don't have a password for it.  So, if you start a AWS account, you can create your own ECR public repository, and password with permissions to upload to your own repository, which is what you are replacing in the script above.

This has some guidance on creating ECR repository:
https://blog.tericcabrel.com/push-docker-image-aws-elastic-container-registry/

Most instructions don't have enough data about the step ..."Retrieve an authentication token and authenticate your Docker client to your registry...".  This means you goto your AWS account, upper-right-corner is [Your name], open that menu, click "security credentials"
Goto the menu on left side "Users".  Click button "create user".  Give name like "publicecr".  Finish creating user.
After user is created, click into user "publicecr" or whatever you named it.  
1) security credentials tab.  Create Access Key.  You need this and the secret key, to when you run "aws configure".
2) permissions tab.  You need to add permission for ECR-public.  The permission to upload to AWS ECR public repository is in a JSON format below.
```
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
```
Then you need to save credentials for AWS, by running 
```
aws configure
```
The above, asks for a secret key and you have to look on internet on guidance on that.


Then after all that is done, run:

```bash
./install_magicmirror.sh pushonly
```

It should look like

```
./install_magicmirror.sh pushonly

... unimportant stuff like checking if running on EC2...

Last metadata expiration check: 0:38:49 ago on Tue 19 Mar 2024 04:24:01 PM PDT.

aws-cli/2.15.2 Python/3.12.1 Linux/6.6.14-200.fc39.x86_64 source/x86_64.fedora.39 prompt/off
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:21 --:--:--     0
curl: (7) Failed to connect to 169.254.169.254 port 80 after 21043 ms: Couldn't connect to server
This security group is assigned to this EC2 instance []
Unable to get security group.  Probably NOT running on AWS EC2 instance

...below is the ECR upload happening....

latest: Pulling from library/node
Digest: sha256:b9ccc4aca32eebf124e0ca0fd573dacffba2b9236987a1d4d2625ce3c162ecc8
Status: Image is up to date for node:latest
docker.io/library/node:latest
[+] Building 0.7s (13/13) FINISHED                               docker:default
 => [internal] load build definition from Dockerfile                       0.1s
 => => transferring dockerfile: 906B                                       0.0s
 => [internal] load metadata for docker.io/library/node:latest             0.0s
 => [internal] load .dockerignore                                          0.2s
 => => transferring context: 2B                                            0.0s
 => [1/8] FROM docker.io/library/node:latest                               0.0s
 => [internal] load build context                                          0.1s
 => => transferring context: 90B                                           0.0s
 => CACHED [2/8] WORKDIR /app                                              0.0s
 => CACHED [3/8] RUN git clone https://github.com/MagicMirrorOrg/MagicMir  0.0s
 => CACHED [4/8] WORKDIR /app/MagicMirror                                  0.0s
 => CACHED [5/8] RUN mkdir logs                                            0.0s
 => CACHED [6/8] RUN npm run install-mm                                    0.0s
 => CACHED [7/8] COPY config.js /app/MagicMirror/config                    0.0s
 => CACHED [8/8] WORKDIR /app/MagicMirror                                  0.0s
 => exporting to image                                                     0.0s
 => => exporting layers                                                    0.0s
 => => writing image sha256:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  0.0s
 => => naming to docker.io/library/mm_serveronly                           0.0s
image created, with a [network broadcast domain]/subnet named nginxbridge
WARNING! Your password will be stored unencrypted in /home/XXXXXX.

Login Succeeded
The push refers to repository [public.ecr.aws/y8w3p2i4/mm-serveronly-defaults]
5f70bf18a086: Pushed 
0cb271d0ed7d: Pushed 
4348735688b8: Pushed 
de5bc18367fc: Pushed 
3c4e21344b35: Pushed 
bd8ed395d6eb: Pushed 
3053dc82b7d3: Pushed 
9b7a370e94a7: Pushed 
5996a891ea4c: Pushed 
5358370f44ab: Pushed 
21e1c4948146: Pushed 
68866beb2ed2: Pushed 
e6e2ab10dba6: Pushed 
0238a1790324: Pushed 
latest: digest: sha256:XXXXXXXX size: 9999
pushed to public ECR repository
```
You should be able to download the image with same tag, you used up upload it.
```
docker pull <tag>
```

