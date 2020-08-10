pipeline {
  environment {
    registry = 'registry.hub.docker.com'
    registryCredential = 'docker-hub'
    repository = 'pvnovarese/jenkins-grype-demo'
    imageLine = 'pvnovarese/jenkins-grype-demo:latest'
  }
  agent any
  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }
    stage('Build image and push to registry') {
      steps {
        sh 'docker --version'
        script {
          docker.withRegistry('https://' + registry, registryCredential) {
            def image = docker.build(repository)
            image.push()
          }
        }
      }
    }
    stage('Analyze with grype') {
      steps {
        // need to actually test this out once I get linux binaries
        sh '/usr/local/bin/grype -o json ${repository}:latest | grep -E 'Critical|High' || exit 0'
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
