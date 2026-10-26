#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_REGION:-us-west-2}"
STACK="${STACK_NAME:-marquis-final-text}"
INPUT=$(aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='InputBucket'].OutputValue" --output text)
OUTPUT=$(aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='OutputBucket'].OutputValue" --output text)
STACK_ID=$(aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query 'Stacks[0].StackId' --output text)
printf 'This permanently deletes test objects and the stack %s.\n' "$STACK"
read -r -p 'Type DELETE to continue: ' answer
[[ "$answer" == DELETE ]] || exit 1
aws s3 rm "s3://$INPUT" --recursive --region "$REGION"
aws s3 rm "s3://$OUTPUT" --recursive --region "$REGION"
aws cloudformation delete-stack --stack-name "$STACK" --region "$REGION"
aws cloudformation wait stack-delete-complete --stack-name "$STACK_ID" --region "$REGION"
aws cloudformation describe-stacks --stack-name "$STACK_ID" --region "$REGION" --query 'Stacks[0].StackStatus' --output text
