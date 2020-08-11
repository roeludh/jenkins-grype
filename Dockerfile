# Dockerfile for jenkins/gripe integration demonstration
# we will use grype to look for High/Critical vulnerabilities
# in the image and kill the jenkins job if we find any
FROM sagikazarmark/dvwa:latest
CMD ["/bin/sh"]
