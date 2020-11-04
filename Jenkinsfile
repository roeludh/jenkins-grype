pipeline {
  environment {
    registry = 'registry.hub.docker.com'
    registryCredential = 'docker-hub'
    repository = 'pvnovarese/jenkins-grype-demo'
  }
  agent any
  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }
    stage('Build image and tag as latest') {
      steps {
        sh 'docker --version'
        script {
          docker.withRegistry('https://' + registry, registryCredential) {
            def image = docker.build(repository)
          }
        }
      }
    }
    stage('Analyze with grype') {
      steps {
        // run grype with json output, use jq just to get severities, concatenate all onto one line,
        // if we find High or Critical vulnerabilities, fail and kill the pipeline
        //
        // old command: sh '/var/jenkins_home/grype -o json ${repository}:latest | jq .[].vulnerability.severity | tr "\n" " " | grep -qvE "Critical|High"'
        // this old command was from before grype had the -f flag (had to do some shell gymnastics to get a fail on critical/high vulns)
        //
        // set -o pipefail enables the entire command to return the failure in grype and still get the count of vulnerability types
        sh 'set -o pipefail ; /var/jenkins_home/grype -f high -q -o json ${repository}:latest | jq .matches[].vulnerability.severity | sort | uniq -c'
      }
    }
    stage('Build and push prod image to registry') {
      steps {
        script {
          docker.withRegistry('https://' + registry, registryCredential) {
            def image = docker.build(repository + ':prod')
            image.push()  
          }
        }
      }
    }
  }
}
