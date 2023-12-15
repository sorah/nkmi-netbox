# The IP address (typically localhost) and port that the Netbox WSGI process should listen on
bind = '0.0.0.0:8001'

# Number of gunicorn workers to spawn. This should typically be 2n+1, where
# n is the number of CPU cores present.
workers = 2

# Number of threads per worker process
threads = 2

# Timeout (in seconds) for a request to complete
timeout = 18

# The maximum number of requests a worker can handle before being respawned
max_requests = 5000
max_requests_jitter = 500