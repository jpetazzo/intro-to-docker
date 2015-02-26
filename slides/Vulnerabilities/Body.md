<!SLIDE>
# Vulnerabilities

When a vulnerability is discovered, it is common practice for
the vendor or community to issue a *security advisory*.

The security advisory will typically indicate:

* The affected software.
* The specific scenarios (if relevant) where the vulnerability
  should be a concern.
* The specific versions affected by the vulnerability.
* The severity of the vulnerability (e.g. can it lead to malfunction,
  or prevent others from using the software or service, or allow
  unauthorized access or modification to data).
* How to remediate it (typically by upgrading affected software).

<!SLIDE>
# Vulnerabilities in Docker

The typical method to deal with Docker vulnerabilities is:

* Stop all containers.
* Stop the Docker daemon.
* Upgrade the Docker daemon.
* Start the Docker daemon.
* Start the container.

<!SLIDE>
# Vulnerabilities in images

If a vulnerability is announced concerning a package that you
are using in your images, you should upgrade those images.

Assuming that updated packages are available, you should:

* Force a `docker pull` of all your base images.
* Re-execute a `docker build --no-cache` of all your built images.
* Re-start all containers using the updated images.

<!SLIDE>
# Detecting vulnerabilities

You can use traditional auditing systems, but Docker provides
new, efficient, non-intrusive ways to perform security audit
and vulnerability reporting.

The use of the `--read-only` flag lets you perform offline
analysis of images to detect those which have vulnerable software.