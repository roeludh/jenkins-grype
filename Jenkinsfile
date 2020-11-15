pipeline {
  environment {
    // shouldn't need the registry variable unless you're not using dockerhub
    registry = 'registry.hub.docker.com'
    // change this registryCredential to the ID of whatever jenkins credential has your registry user/pass
    registryCredential = 'docker-hub'
    // change repository to your DockerID
    repository = 'pvnovarese/jenkins-grype-demo'
  }
  agent any
  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }
    stage('Build image and tag with build number') {
      steps {
        script {
          dockerImage = docker.build repository + ":${BUILD_NUMBER}"
        }
      }
    }
    stage('Analyze with grype') {
      steps {
        // run grype with json output, use jq just to get severities, 
        // concatenate all onto one line, if we find High or Critical 
        // vulnerabilities, fail and kill the pipeline
        // 
        // old command: 
        // sh '/var/jenkins_home/grype -o json ${repository}:latest | \
        // jq .[].vulnerability.severity | tr "\n" " " | \
        // grep -qvE "Critical|High"'
        // 
        // this old command was from before grype had the -f flag (had to do 
        // some shell gymnastics to get a fail on critical/high vulns by 
        // concatenating everything onto one line and then using grep -v
        //
        // set -o pipefail enables the entire command to return the failure 
        // in grype and still get the count of vulnerability types
        // 
        sh 'set -o pipefail ; /var/jenkins_home/grype -f critical -q -o json ${repository}:latest | jq .matches[].vulnerability.severity | sort | uniq -c'
      }
    }
    stage('Re-tag as prod and push stable image to registry') {
      steps {
        script {
          docker.withRegistry('', registryCredential) {
            dockerImage.push('prod') 
            // dockerImage.push takes the argument as a new tag for the image before pushing
          }
        }
      }
    }
  }
}
