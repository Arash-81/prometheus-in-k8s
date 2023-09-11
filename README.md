# Monitoring domains with Prometheus in Kubernetes

### ping-bash

First, I wrote a `ping-script.sh` script that uses the ping command to ping domains provided in the `ping-urls` config map every 30 seconds. The script saves the data in a shared file called `/data/ping.txt`, which I created a volume for this in the deployment YAML file.

[!NOTE]
To prevent race conditions, I created a `lock` file to set a mutex for preventing read/write access by Python and Bash.

---

### pyExporter

This code uses the Prometheus client library to export a gauge metric called my_inprogress_requests. The metric tracks the value for each domain and type.

The code first starts a Prometheus HTTP server on port 8000. Then, it enters a loop where it checks the /data/lock file. If the file contains the string "mutex is 1", then the code executes the ping_values() function. This function reads the data from the /data/ping.txt file and exports the metrics to Prometheus. After the ping_values() function is executed, the code writes the string "mutex is 0" to the /data/lock file and sleeps for 30 seconds.

If the /data/lock file does not contain the string "mutex is 1", then the code sleeps for 5 seconds.

---

### ping-deployment

This Kubernetes deployment YAML file deploys two containers:

- A `ping-bash` container that runs the `ping-script.sh` script to ping domains provided in the `ping-urls` config map.
- A `exporter` container that runs the `pyExporter.py` script to export metrics from the `ping-bash` container to Prometheus.

The `ping-bash` container mounts two volumes:

- The `config-volume`, which is a config map that contains the list of domains to ping.
The `emptydir-volume`, which is an empty directory that is used to store the results of the ping commands.

The `exporter` container mounts the `emptydir-volume` volume, which is used to store the metrics exported by the `pyExporter.py` script.