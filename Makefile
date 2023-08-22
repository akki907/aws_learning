# Makefile for deploying React app to S3

# Configuration
AWS_REGION = us-east-1

# Command Aliases
NPM = npm
AWS = aws
OPEN = open
ifeq ($(OS),Windows_NT)
    OPEN = start
endif

deploy:
	./scrips/s3-deploy-dev.sh

remove:
	$(AWS) s3 ls; \
	read -p "Enter the bucket name to remove: " BUCKET_NAME; \
	$(AWS) s3 rb s3://$$BUCKET_NAME --force; \
	echo "Bucket $$BUCKET_NAME removed."