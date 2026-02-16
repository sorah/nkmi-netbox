from os import environ


def _whitenoise_add_headers(headers, path, url):
    headers['Cache-Control'] = 'max-age=300, public, s-maxage=31536000, stale-while-revalidate=900'


WHITENOISE_ADD_HEADERS_FUNCTION = _whitenoise_add_headers

STORAGES = {
    'default': {
        'BACKEND': 'storages.backends.s3boto3.S3Boto3Storage',
        'OPTIONS': {
            'bucket_name': environ.get('AWS_STORAGE_BUCKET_NAME', ''),
        },
    },
}
