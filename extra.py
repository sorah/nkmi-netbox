from os import environ

STORAGES = {
    'default': {
        'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage',
        'OPTIONS': {
            'bucket_name': environ.get('AWS_STORAGE_BUCKET_NAME', ''),
        },
    },
}
