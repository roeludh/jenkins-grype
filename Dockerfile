# Dockerfile for jenkins/gripe integration demonstration
# we will use grype to look for High/Critical vulnerabilities
# in the image and kill the jenkins job if we find any

# pvnovarese/ubuntu_sudo_test should have 1 known "high" severity 
# issue in it (CVE-2021-3156 - sudo), but if you want something
# with more issues in it, try FROM sagikazarmark/dvwa:latest
# (this is a much larger image, though)

FROM pvnovarese/ubuntu_sudo_test:latest
CMD ["/bin/false"]
