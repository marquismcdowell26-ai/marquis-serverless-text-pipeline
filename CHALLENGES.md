# Implementation notes

- Before deployment, local AWS CLI authentication failed with `IncompleteSignature`. Used the authenticated AWS console and CloudShell instead; no credentials were copied into this repository.
- Created and committed the architecture before deploying resources (initial commit `3ea4a4e`).
- Avoided the S3 notification/Lambda permission dependency cycle by using a predictable input bucket name and explicitly making the bucket depend on its Lambda invoke permission.
- A first local test had an incorrect expected count of 11. Manual recount confirmed 10 whitespace-separated words, and the expectation was corrected. The word-count logic did not change.
- AWS CloudFormation template validation succeeded. This validates template structure, not a successful deployment or runtime behavior.
- Two local tests passed: event/key decoding and result generation, and rejection of text files larger than 1 MiB. These use a fake S3 client; live testing is tracked separately.
- The full assignment supplied during implementation required at least four listed architecture elements. Updated and committed the diagram before extending the stack with DynamoDB and a CloudWatch error alarm; also added HTTPS-only S3 bucket policies.
- A pasted live-test command initially contained an unintended line break inside a Python string and failed before uploading anything. Corrected the command quoting and reran it.
