import json
import os
import urllib.parse
import boto3

s3 = boto3.client('s3')
dynamodb = boto3.client('dynamodb')
MAX_BYTES = 1048576

def handler(event, context):
    results = []
    for record in event.get('Records', []):
        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'])
        response = s3.get_object(Bucket=bucket, Key=key)
        if response['ContentLength'] > MAX_BYTES:
            response['Body'].close()
            raise ValueError('Text file exceeds 1 MiB limit')
        text = response['Body'].read(MAX_BYTES + 1).decode('utf-8')
        result = {
            'project': os.environ['PROJECT_NAME'],
            'source_file': key,
            'word_count': len(text.split()),
            'character_count': len(text),
            'status': 'processed'
        }
        output_key = key + '.json'
        s3.put_object(Bucket=os.environ['OUTPUT_BUCKET'], Key=output_key,
                      Body=json.dumps(result, indent=2).encode('utf-8'),
                      ContentType='application/json')
        dynamodb.put_item(TableName=os.environ['RESULTS_TABLE'], Item={
            'source_file': {'S': key},
            'project': {'S': result['project']},
            'word_count': {'N': str(result['word_count'])},
            'character_count': {'N': str(result['character_count'])},
            'status': {'S': 'processed'}
        })
        print(json.dumps(result))
        results.append(result)
    return {'processed': len(results), 'results': results}
