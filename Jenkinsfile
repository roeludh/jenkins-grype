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
        // run grype, if we find High or Critical vulnerabilities, fail and kill the pipeline
        sh '/var/jenkins_home/grype ${repository}:latest | tr "\n" " " | grep -qv "Critical|High"'
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
