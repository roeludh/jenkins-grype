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
    REPOSITORY = "${DOCKER_HUB_USR}/jenkins-grype"
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
        // set -o pipefail enables the entire command to return the failure 
        // in grype and still get the count of vulnerability types
        // 
        // you can change this from "high" to "critical" if you want to see 
        // the command succeed since pvnovarese/ubuntu_sudo_test doesn't (as 
        // of today) have any critical vulns in it, just high.
        //
        script {
          try {
            // -f high --> fail if "high" or "critical" vulns detected
            // we don't really need to pipe into jq if we're just testing
            // for vulns, but this way we can get some output to provide
            // to devs as feedback.
            //
            sh 'set -o pipefail ; /usr/local/bin/grype -f high -q ${REPOSITORY}:${BUILD_NUMBER}'
          } catch (err) {
            // if scan fails, clean up (delete the image) and fail the build
            sh """
              echo "Vulnerabilities detected in ${REPOSITORY}:${BUILD_NUMBER}, cleaning up and failing build."
              docker rmi ${REPOSITORY}:${BUILD_NUMBER}
              exit 1
            """
          } // end try/catch
        } // end script
      } // end steps
    } // end stage "analyze with grype"
    
    stage('Re-tag as prod and push stable image to registry') {
      steps {
        sh """
          docker tag ${REPOSITORY}:${BUILD_NUMBER} ${REPOSITORY}:prod
          docker push ${REPOSITORY}:prod
        """
      } // end steps
    } // end stage "retag as prod"

    stage('Clean up') {
      // delete the images locally
      steps {
        sh 'docker rmi ${REPOSITORY}:${BUILD_NUMBER} ${REPOSITORY}:prod'
      } // end steps
    } // end stage "clean up"

  } // end stages
} // end pipeline
