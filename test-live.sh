#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_REGION:-us-west-2}"
STACK="${STACK_NAME:-marquis-final-text}"
INPUT=$(aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='InputBucket'].OutputValue" --output text)
OUTPUT=$(aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='OutputBucket'].OutputValue" --output text)
mkdir -p evidence
aws s3 cp sample.txt "s3://$INPUT/sample.txt" --region "$REGION"
for attempt in {1..30}; do
  if aws s3 cp "s3://$OUTPUT/sample.txt.json" evidence/result.json --region "$REGION" 2>/dev/null; then break; fi
  sleep 2
done
python3 - <<'PY'
import json
from pathlib import Path
r=json.loads(Path('evidence/result.json').read_text())
assert r['word_count']==10, r
assert r['project']=="marquis's final", r
assert r['status']=='processed', r
print(json.dumps(r,indent=2))
print('LIVE TEST PASSED')
PY
TABLE=$(aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='ResultsTable'].OutputValue" --output text)
for attempt in {1..15}; do
  aws dynamodb get-item --table-name "$TABLE" --key '{"source_file":{"S":"sample.txt"}}' --consistent-read --region "$REGION" --output json > evidence/dynamodb-result.json
  if python3 -c 'import json; r=json.load(open("evidence/dynamodb-result.json")); assert r["Item"]["word_count"]["N"]=="10"' 2>/dev/null; then break; fi
  sleep 2
done
python3 -c 'import json; r=json.load(open("evidence/dynamodb-result.json")); assert r["Item"]["word_count"]["N"]=="10"; print("DYNAMODB TEST PASSED")'
aws logs tail "/aws/lambda/$STACK-counter" --since 10m --region "$REGION" --no-cli-pager
