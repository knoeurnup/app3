pipeline {
    agent any
    
    environment {
        TELEGRAM_BOT_TOKEN = '7309710230:AAHVqKKUkJ4yNxLfh8imyGxamgqctNRaHC0'
        TELEGRAM_CHAT_ID = '-4210903621'
        
        // Swarm Server 
        REMOTE_SERVER = '172.31.24.161'
        REMOTE_USER = 'root'
        REMOTE_FILE_ENV_PATH = '/opt/assI/deploy/ms-demo/ms-deployment/.env'
        REMOTE_FILE_SCRIPT_PATH = '/opt/assI/deploy/ms-demo/ms-deployment/start.sh'

        // Docker Registry
        DOCKER_REGISTRY_SERVER = 'knoeurn'
        DOCKER_IMAGE="app3"
        DOCKER_REGISTRY_USER = 'knoeurn'
        DOCKER_REGISTRY_PASSWORD = 'Knoeurn@3636'
        
        // Current Docker image tage
        CURRENT_VERSION = sh(script: "curl -s https://registry.hub.docker.com/v2/repositories/${env.DOCKER_REGISTRY_SERVER}/${env.DOCKER_IMAGE}/tags | jq -r '.results[].name' | sort -r | head -n 1", returnStdout: true).trim()
    
    }

    stages {
        stage('Checkout') {
            steps {
              script {
                try {
                  sendTelegramMessage( "Starting the checkout https://github.com/knoeurnup/app3.git") ;
                  // Clone the repository
                  git branch: 'main', url: 'https://github.com/knoeurnup/app3.git'
                
                  sendTelegramMessage('Checkout process was successfully')
                 
                }catch (Exception e) {
                  sendTelegramMessage("Error during checkout process : ${e.message}")
                  currentBuild.result = 'FAILURE'
                  throw e
                }
              }
            }
        }
        stage('Build Docker Image'){
            steps{
              script{
               
                try{
                  def newVersion = getNewVersion()
                  sendTelegramMessage( "Starting to build docker image : ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${newVersion} ")

                  sh  "docker build -t ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${newVersion} ."

                  sendTelegramMessage( "Build docker image process of ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${newVersion} completed successfully.")
                }catch (Exception e) {
                  sendTelegramMessage( "Error during build new image ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${getNewVersion()}: ${e.message}")
                  currentBuild.result = 'FAILURE'
                  throw e
                }
              }
            }
        }
        stage('Push Docker Image'){
            steps {
              script{
                try{
                  def currentVersion = getNewVersion()
                  sendTelegramMessage( "Starting to push image : ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${currentVersion} " ) ;
                  sh(script: "docker push ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${currentVersion}", returnStatus: true)

                  sendTelegramMessage( "This image ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${currentVersion} was successfully pushed to the server")
                  
                }catch (Exception e) {
                  sendTelegramMessage( "Error during push docker image ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${getNewVersion()} : ${e.message}")
                  currentBuild.result = 'FAILURE'
                  throw e
                }
              }
            }
        }
        stage('Update Swarm Version'){
         steps{
            script{
                 try{
                     sendTelegramMessage( "Updating : ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${getNewVersion()} " ) ;
                     // Execute SSH command to read the content of the .env file
                      def command = """
                      ssh ${env.REMOTE_USER}@${env.REMOTE_SERVER} 'cat ${env.REMOTE_FILE_ENV_PATH}'
                      """
                      
                      // Read the .env file content
                      def envFileContent = sh(script: command, returnStdout: true).trim()
                      
                      // Print the content of the .env file
                      echo "Content of .env original file:\n${envFileContent}"
                       def newEnvironmentFileContent = "# .env file\n"
                      // Process the .env file content, e.g., parse and set environment variables
                      envFileContent.tokenize('\n').each { line ->
                          def parts = line.split('=')
                          if (parts.size() == 2) {
                              def key = parts[0].trim()
                              def value = parts[1].trim()
                              // Set the environment variable in the Jenkins pipeline
                            //   env[key] = value
                            echo "key:" + key +" => " + value
                            if(key=="APP3_VERSION"){
                                if(value!= getNewVersion()){
                                    newEnvironmentFileContent +="${key}=${getNewVersion()}"
                                }
                            }else if(key=="APP1_VERSION"){
                                newEnvironmentFileContent +="${key}=${value}\n"
                            }else if(key=="APP2_VERSION"){ 
                                newEnvironmentFileContent +="${key}=${value}\n"
                            }
                          }
                      }
                      echo "Content of .env new file:\n${newEnvironmentFileContent}"
                    //   echo "Content of .env new file:\n${newEnvironmentFileContent}"
                      echo "Current verion: ${env.CURRENT_VERSION}"
                      echo "new Verion:${getNewVersion()}"
                       // Define the SSH command to rewrite the file
                        def commandWrite = """
                        ssh ${env.REMOTE_USER}@${env.REMOTE_SERVER} 'echo "${newEnvironmentFileContent}" > ${env.REMOTE_FILE_ENV_PATH}'
                        """
                        
                        // Execute the SSH command and capture the return status
                        def status = sh(script: commandWrite, returnStatus: true)
                        
                        // Handle errors if the SSH command fails
                        if (status != 0) {
                            sendTelegramMessage( "Failed to rewrite the file on the remote server. SSH command returned status ${status}.")
                        }
                     sendTelegramMessage( "Updated : ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${getNewVersion()} " ) ;
                  }catch(Exception e){
                      sendTelegramMessage( "Error during upding  ${env.DOCKER_REGISTRY_USER}/${env.DOCKER_IMAGE}:${getNewVersion()} docker swarm image version in .env : ${e.message}")
                      currentBuild.result = 'FAILURE'
                      throw e
                  }
            } 
         }
        }
        stage('Deploy'){
            steps {
              script{
                try{
        
                    sendTelegramMessage( "Preparing deploy ${env.DOCKER_REGISTRY_SERVER}/${env.DOCKER_IMAGE}:${getNewVersion()} into swarm" ) ;
    
                    def status = sh(script: "ssh ${env.REMOTE_USER}@${env.REMOTE_SERVER} ${REMOTE_FILE_SCRIPT_PATH}", returnStatus: true)
                    if (status != 0) {
                        sendTelegramMessage( "Failed to deploy swarm manager. SSH command returned status ${status}.")
                        currentBuild.result = 'FAILURE'
                        throw e
                    }       
                    else sendTelegramMessage( "The ${env.DOCKER_REGISTRY_SERVER}/${env.DOCKER_IMAGE}:${getNewVersion()} was deployed successfully into swarm")
                  }catch (Exception e) {
                    sendTelegramMessage( "Error during deploy process : ${e.message}")
                     currentBuild.result = 'FAILURE'
                      throw e
                  }
              }
            }
        }
    }

    post {
        failure {
            sendTelegramMessage( "This block (failture) runs when the build is failed.")
        }
        success {
            sendTelegramMessage( "This block (success) runs when the build is succeeded.")
        }
    }
}

def sendTelegramMessage(String message) {
    httpRequest(
        acceptType: 'APPLICATION_JSON',
        contentType: 'APPLICATION_JSON',
        httpMode: 'POST',
        url: "https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}/sendMessage",
        requestBody: "{\"chat_id\": \"${env.TELEGRAM_CHAT_ID}\", \"text\": \"${message}\"}"
    )
}

def getNewVersion(){
    def versionParts = env.CURRENT_VERSION.tokenize('.')
    def major = versionParts[0].toInteger()
    def minor = versionParts[1].toInteger()
    def patch = versionParts[2].toInteger()
    
    // Increment the patch number
    patch += 1
    
    // Construct the new version string
    def newVersion = "${major}.${minor}.${patch}"
    return newVersion                
}

