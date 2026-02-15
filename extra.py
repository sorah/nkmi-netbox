from os import environ


def _whitenoise_add_headers(headers, path, url):
    cc = headers.get('Cache-Control', '')
    if cc and 's-maxage' not in cc:
        headers['Cache-Control'] = f"{cc}, s-maxage=86400"


WHITENOISE_ADD_HEADERS_FUNCTION = _whitenoise_add_headers

STORAGES = {
    'default': {
        'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage',
        'OPTIONS': {
            'bucket_name': environ.get('AWS_STORAGE_BUCKET_NAME', ''),
        },
    },
}
