from prometheus_client import start_http_server, Gauge
import psutil
from ping3 import ping, verbose_ping
import time

# Create Prometheus metrics
disk_total = Gauge('disk_total', 'Total disk space')
disk_used = Gauge('disk_used', 'Used disk space')
disk_free = Gauge('disk_free', 'Free disk space')
ping_latency = Gauge('ping_latency_ms', 'Ping latency to 8.8.8.8 in milliseconds')

def update_disk_metrics():
    disk = psutil.disk_usage('/')
    disk_total.set(disk.total)
    disk_used.set(disk.used)
    disk_free.set(disk.free)

def update_ping_metric():
    response_time = ping('8.8.8.8')
    if response_time is not None:
        ping_latency.set(response_time * 1000)  # Convert to milliseconds

if __name__ == '__main__':
    # Start an HTTP server to expose metrics on :8000/metrics
    start_http_server(8000)

    while True:
        update_disk_metrics()
        update_ping_metric()
        time.sleep(5)  # Update metrics every 5 seconds

# Packops Monitoring_Stack Course 2023
