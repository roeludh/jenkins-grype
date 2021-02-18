pipeline {
  environment {
    // shouldn't need the registry variable unless you're not using dockerhub
    // registry = 'registry.hub.docker.com'
    //
    // change this HUB_CREDENTIAL to the ID of whatever jenkins credential has your registry user/pass
    // first let's set the docker hub credential and extract user/pass
    // we'll use the USR part for figuring out where are repository is
    HUB_CREDENTIAL = "docker-hub"
    // use credentials to set DOCKER_HUB_USR and DOCKER_HUB_PSW
    DOCKER_HUB = credentials("${HUB_CREDENTIAL}")
    // change repository to your DockerID
    REPOSITORY = "${DOCKER_HUB_USR}/jenkins-grype-demo"
  } // end environment
  
  agent any
  stages {
    
    stage('Checkout SCM') {
      steps {
        checkout scm
      } // end steps
    } // end stage "checkout scm"
    
    stage('Build image and tag with build number') {
      steps {
        script {
          dockerImage = docker.build REPOSITORY + ":${BUILD_NUMBER}"
        } // end script
      } // end steps
    } // end stage "build image and tag w build number"
    
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
        // you can change this from "high" to "critical" if you want to see 
        // the command succeed since dvwa doesn't (as of today) have any 
        // critical vulns in it, just a bunch of highs
        //
        sh 'set -o pipefail ; /var/jenkins_home/grype -f high -q -o json ${REPOSITORY}:${BUILD_NUMBER} | jq .matches[].vulnerability.severity | sort | uniq -c'
      } // end steps
    } // end stage "analyze with grype"
    
    stage('Re-tag as prod and push stable image to registry') {
      steps {
        script {
          docker.withRegistry('', HUB_CREDENTIAL) {
            dockerImage.push('prod') 
            // dockerImage.push takes the argument as a new tag for the image before pushing
          }
        } // end script
      } // end steps
    } // end stage "retag as prod"

    stage('Clean up') {
      // delete the images locally
      steps {
        sh 'docker rmi ${REPOSITORY}${TAG} ${REPOSITORY}:prod'
      } // end steps
    } // end stage "clean up"

  } // end stages
} // end pipeline
