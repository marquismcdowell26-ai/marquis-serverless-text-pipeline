#!/usr/bin/env bash
set -euo pipefail
# Run from the repository root in an authenticated AWS CLI or AWS CloudShell.
REGION="${AWS_REGION:-us-west-2}"
STACK="${STACK_NAME:-marquis-final-text}"
aws sts get-caller-identity --no-cli-pager
aws cloudformation validate-template --template-body file://template.json --region "$REGION" --no-cli-pager
aws cloudformation deploy --template-file template.json --stack-name "$STACK" --capabilities CAPABILITY_IAM --region "$REGION" --no-cli-pager
aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query 'Stacks[0].Outputs' --no-cli-pager
