#!/bin/bash

AWS_REGION="us-east-1"

# Build React app
npm install
npm run build


# Ask user for the bucket name
echo "Enter a unique bucket name: "

read  BUCKET_NAME

# Set bucket policy for public access
BUCKET_POLICY='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::'$BUCKET_NAME'/*"
            ]
        }
    ]
}'

# Create S3 bucket
aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION
echo "bucket created $BUCKET_NAME"

# Enable static website hosting
aws s3 website s3://$BUCKET_NAME/ --index-document index.html
echo "Enable static website hosting"

# Disable "Block all public access"
aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
echo "Disable 'Block all public access'"


# Set bucket policy for public access
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy "$BUCKET_POLICY"


# Upload build to S3
aws s3 sync build/ s3://$BUCKET_NAME
echo "Upload build to S3"


# Print the deployed app URL
echo "Your React app is deployed at: http://$BUCKET_NAME.s3-website.$AWS_REGION.amazonaws.com"

echo "Open default browser"
# Open default browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    open "http://$BUCKET_NAME.s3-website.$AWS_REGION.amazonaws.com"
elif [[ "$OSTYPE" == "msys"* ]]; then
    start "http://$BUCKET_NAME.s3-website.$AWS_REGION.amazonaws.com"
fi