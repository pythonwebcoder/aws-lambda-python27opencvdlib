# Python OpenCV+DLIB module for AWS Lambda

## IN WORK - YMMV

## Description
This is a simple script that builds a deployment package including OpenCV compatible with the AWS Lambda Python runtime. The dynamic library is compiled with all extended instruction sets supported by Lambda CPU and binaries are stripped to save space. You simply need to add your code inside *lambda_function.py* and possibly your additional data files and additional Python modules.  Currently this is for Python 2.x.

**original work for this was forked from: https://github.com/aeddi/aws-lambda-python-opencv**
**Needs to be built on an Amazon Linux instance. dlib requires some memory to build so T2.XX should be used**

## Module building
### Option 1: with an existing instance
- Download the repo `wget https://github.com/dudash/aws-lambda-python-opencv/archive/master.zip`
- Unzip the archive `unzip master.zip`
- Launch the script `cd aws-lambda-python-opencv-master && ./build.sh`

### Option 2: without an existing instance
In the EC2 console, launch a new instance with:
- Amazon Linux AMI
- Role with S3 write permission
- Shutdown behavior: *Terminate*
- Make sure to auto assign a public IP
- Under Advanced Details - paste the script below in the user data text field
```bash
#!/bin/bash
yum update -y
yum install -y git cmake gcc-c++ gcc python-devel chrpath

cd /tmp
wget https://github.com/dudash/aws-lambda-python-opencv/archive/master.zip
unzip master.zip
chmod 777 aws-lambda-python-opencv-master
cd aws-lambda-python-opencv-master
su -c './build.sh' ec2-user

aws s3 cp lambda-package.zip s3://<my-target-bucket>
shutdown -h now
```
- Replace *my-target-bucket* by a bucket where you want to store this lambda function
- Less than 30 min later the instance will be terminated and the archive will be available on your bucket
- You can check status of the build with `aws ec2 get-console-output --instance-id i-XXXXXXXXXXXXXXXXXX`
