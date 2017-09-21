import cv2
import dlib
import numpy as np
import os
import boto3

print os.environ

# Setup AWS access and S3 buckets
S3OUTBUCKET = os.environ.get('S3OUTBUCKET')
S3INBUCKET = os.environ.get('S3INBUCKET')
s3 = boto3.resource('s3')
for bucket in s3.buckets.all():
    print(bucket.name)

def lambda_handler(event, context):
	print "OpenCV version=", cv2.__version__
	print "np version=", np.__version__
	return "It works!"

if __name__ == "__main__":
	lambda_handler(42, 42)
