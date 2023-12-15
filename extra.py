from os import environ

STORAGE_BACKEND = 'storages.backends.s3boto3.S3Boto3Storage'
STORAGE_CONFIG = {
    "AWS_STORAGE_BUCKET_NAME": environ.get('AWS_STORAGE_BUCKET_NAME', '')
}
