from prometheus_client import start_http_server, Gauge
import time

g = Gauge('my_inprogress_requests', 'Description of gauge', ['domain', 'type'])

def ping_values():
     with open("/data/ping.txt", "r") as f:
        lines = f.readlines()
        for line in lines:
            domain, type, value = line.split()
            g.labels(domain=domain, type=type).set(value)

        open('/data/ping.txt', 'w').close()

if __name__ == '__main__':
    start_http_server(8000)
    while True:
        with open("/data/lock", "r+") as lock:
            line = lock.readline().strip()
            if line == "mutex is 1":
                ping_values()
                lock.seek(0)
                lock.write("mutex is 0")
                time.sleep(30)
            else:
                time.sleep(5)
