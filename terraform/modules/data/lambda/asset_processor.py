import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")


def handler(event, context):
    """
    Triggered on S3 ObjectCreated events in the bedrock-assets bucket.
    Logs metadata about the uploaded object. Extend this to do real
    processing (image resize, virus scan, thumbnail generation, etc.)
    """
    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        size = record["s3"]["object"].get("size", 0)

        logger.info(f"Processing new object: s3://{bucket}/{key} ({size} bytes)")

        try:
            head = s3.head_object(Bucket=bucket, Key=key)
            content_type = head.get("ContentType", "unknown")
            logger.info(f"Content-Type: {content_type}")
        except Exception as e:
            logger.error(f"Failed to read metadata for {key}: {e}")

    return {
        "statusCode": 200,
        "body": json.dumps({"processed": len(event.get("Records", []))}),
    }