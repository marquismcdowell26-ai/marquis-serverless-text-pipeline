# Live verification

Observed in authenticated AWS CloudShell on October 25, 2026 (Pacific time).

- Stack: marquis-final-text, region us-west-2, UPDATE_COMPLETE.
- Uploaded sample.txt to the input bucket; S3 triggered Lambda.
- S3 result: project "marquis's final", word_count 10, character_count 76, status processed.
- DynamoDB consistent read returned the matching source_file, project, word_count, character_count and status.
- The live script asserted both counts and the project label, then printed LIVE TEST PASSED.
- result.json is a transcription of the verified cloud output, not an additional test run. Screenshots provide the visual evidence.
