import cv2
import dlib
import numpy as np
import os
import boto3
import botocore

#print os.environ

# Setup AWS access and S3 buckets
S3OUTBUCKET = os.environ.get('S3OUTBUCKET')
S3INBUCKET = os.environ.get('S3INBUCKET')
TESTS3KEY = '59bf0c6bbb886c5a69d758e3-59bf0c6c301edb5a46a1643c.png' # replace with your object key
s3 = boto3.resource('s3')
try:
    s3.Bucket(S3INBUCKET).download_file(TESTS3KEY, '59bf0c6bbb886c5a69d758e3-59bf0c6c301edb5a46a1643c.png')
except botocore.exceptions.ClientError as e:
    if e.response['Error']['Code'] == "404":
        print("The object does not exist.")
    else:
        raise

def lambda_handler(event, context):
	print "OpenCV version=", cv2.__version__
	print "np version=", np.__version__
	print "context=", context
	return "yay, it works!"

if __name__ == "__main__":
	lambda_handler(42, 42)
