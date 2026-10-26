import importlib.util
import io
import json
import os
from pathlib import Path
import sys
import types
import unittest

class FakeS3:
    payload = b'Hello from Marquis. This serverless AWS project counts words automatically.\n'
    def get_object(self, **kwargs):
        self.read = kwargs
        return {'ContentLength':len(self.payload),'Body':io.BytesIO(self.payload)}
    def put_item(self, **kwargs):
        self.item = kwargs
    def put_object(self, **kwargs):
        self.written = kwargs

s3 = FakeS3()
sys.modules['boto3'] = types.SimpleNamespace(client=lambda name:s3)
spec = importlib.util.spec_from_file_location('counter',Path(__file__).parents[1]/'src/index.py')
counter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(counter)
os.environ.update(OUTPUT_BUCKET='test-results',RESULTS_TABLE='test-table',PROJECT_NAME="marquis's final")

class CounterTests(unittest.TestCase):
    def test_realistic_event(self):
        result = counter.handler({'Records':[{'s3':{'bucket':{'name':'test-input'},'object':{'key':'my+sample.txt'}}}]},None)
        self.assertEqual(result['processed'],1)
        self.assertEqual(s3.read['Key'],'my sample.txt')
        saved = json.loads(s3.written['Body'])
        self.assertEqual(saved['word_count'],10)
        self.assertEqual(saved['project'],"marquis's final")
        self.assertEqual(s3.written['Key'],'my sample.txt.json')
        self.assertEqual(s3.item['Item']['word_count']['N'],'10')
    def test_large_file_rejected(self):
        prior=s3.payload
        try:
            s3.payload=b'x'*(1048576+1)
            with self.assertRaises(ValueError):
                counter.handler({'Records':[{'s3':{'bucket':{'name':'test-input'},'object':{'key':'large.txt'}}}]},None)
        finally:s3.payload=prior

if __name__=='__main__':unittest.main()
