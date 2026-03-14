#!/bin/bash

echo "---------------------------------------"
echo "Databricks Auto Deployment Started"
echo "---------------------------------------"

REPO_URL="https://github.com/NirmalaD9/free-trial-dab-project.git"
PROJECT_DIR="free-trial-dab-project"
BRANCH="main"

TARGET="dev"
PROFILE="test"

JOB_NAME="auto_pipeline_job"
PIPELINE_NAME="auto_dlt_pipeline"

# Check if repo exists
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Cloning project from GitHub..."
  git clone $REPO_URL
fi

# Go to project folder
cd $PROJECT_DIR || exit

echo "Pulling latest code..."
git pull origin $BRANCH

echo "---------------------------------------"
echo "Validating Databricks bundle..."
echo "---------------------------------------"

databricks bundle validate -t $TARGET --profile $PROFILE

# Stop script if validation fails
if [ $? -ne 0 ]; then
  echo "Validation failed. Stopping deployment."
  exit 1
fi

echo "---------------------------------------"
echo "Deploying bundle..."
echo "---------------------------------------"

databricks bundle deploy -t $TARGET --profile $PROFILE

if [ $? -ne 0 ]; then
  echo "Deployment failed."
  exit 1
fi

echo "---------------------------------------"
echo "Running DLT Pipeline..."
echo "---------------------------------------"

databricks bundle run $PIPELINE_NAME -t $TARGET --profile $PROFILE

if [ $? -ne 0 ]; then
  echo "Pipeline run failed."
  exit 1
fi

echo "---------------------------------------"
echo "Running Job..."
echo "---------------------------------------"

databricks bundle run $JOB_NAME -t $TARGET --profile $PROFILE

if [ $? -ne 0 ]; then
  echo "Job run failed."
  exit 1
fi

echo "---------------------------------------"
echo "Deployment Completed Successfully"
echo "---------------------------------------"
