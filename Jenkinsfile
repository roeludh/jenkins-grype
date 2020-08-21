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
        sh '/var/jenkins_home/grype -o json ${repository}:latest | jq .[].vulnerability.severity | tr "\n" " " | grep -qvE "Critical|High"'
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
