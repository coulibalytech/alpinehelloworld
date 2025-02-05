pipeline{
          environment{
              IMAGE_NAME = "alpinehellowolrd"
              IMAGE_TAG = "v1.1"
              STAGING = "coulibaltech-staging"
              PRODUCTION = "coulibaltech-production"
              REPOSITORY_NAME = "coulibalytech"

            // Staging EC2
              STAGING_IP = "44.211.159.237"
              STAGING_USER = "ubuntu"
              STAGING_DEPLOY_PATH = "/home/ubuntu/app/staging"
              STAGING_HTTP_PORT = "5000" // Port spécifique pour staging

             // Production EC2
              PRODUCTION_IP = "34.238.39.56"
              PRODUCTION_USER = "ubuntu"
              PRODUCTION_DEPLOY_PATH = "/home/ubuntu/app/production"
              PRODUCTION_HTTP_PORT = "5000" // Port spécifique pour production

              SSH_CREDENTIALS_ID = "ec2_ssh_credentials"
              DOCKERHUB_CREDENTIALS = 'dockerhub-credentials-id'
          }
          agent none
          stages{
                stage("Build image") {
                    agent any
                    steps{
                        echo "========executing Build image========"
                        script{
                            sh 'docker build -t $REPOSITORY_NAME/$IMAGE_NAME:$IMAGE_TAG .'
                        }
                    }
                    
                }
                stage("Run container based on builded image") {
                    agent any
                    steps{
                        echo "========executing Run container based on builded image========"
                        script{
                            sh '''
                            docker run --name $IMAGE_NAME -d -p 80:5000 -e PORT=5000 $REPOSITORY_NAME/$IMAGE_NAME:$IMAGE_TAG
                            sleep 5

                                '''
                        }
                    }
                    
                }
                stage("Test image") {
                    agent any
                    steps{
                        echo "========executing Test image========"
                        script{
                            sh 'curl http://172.17.0.1 | grep -q "Hello world!"'
                        }
                    }
                    
                }

                stage("Login to Docker Hub Registry") {
                    agent any      
                    steps {
                            script {
                                echo "Connexion au registre Docker hub"
                            withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                                sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                           }
                       }
                    }

                }

                stage('Push Image in docker hub') {
                        agent any
                        steps {
                            script {
                                echo "Pousser l'image Docker vers le registre..."
                                sh "docker push ${REPOSITORY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
                                sh "docker logout"      
                            }
                        }
                    }
                 
               stage("Clean container") {
                  agent any
                  steps{
                      echo "========executing Clean container========"
                      script{
                        sh '''
                        docker stop $IMAGE_NAME
                        docker rm $IMAGE_NAME

                          '''
                       }
                   }
                  
                }
            
                stage("Deploy in staging") {
                  when{
                      expression {GIT_BRANCH == 'origin/master'}
                    }
                  agent any
            
                  steps{
                      echo "========executing Deploy in staging========"
                      
                      script{
                            sh 'docker save $REPOSITORY_NAME/$IMAGE_NAME:${IMAGE_TAG} > $IMAGE_NAME.tar'
                            sshagent (credentials: [SSH_CREDENTIALS_ID]) {
                                sh """
                                echo "Uploading Docker image to Staging EC2"
                                ssh ${STAGING_USER}@${STAGING_IP}'
                                    docker stop ${REPOSITORY_NAME}/${IMAGE_NAME}
                                    docker rm ${REPOSITORY_NAME}/${IMAGE_NAME}
                                    docker rmi ${REPOSITORY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                                    docker pull ${REPOSITORY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                                    docker run --name staging_${IMAGE_NAME} -d -p 80:${STAGING_HTTP_PORT} -e PORT=${STAGING_HTTP_PORT} ${REPOSITORY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}'
                                """

                            }
                        
                        }
                    }
                }

                stage("Deploy in production") {
                  when{
                      expression {GIT_BRANCH == 'origin/master'}
                  }
                  agent any

                  steps{
                      echo "========executing Deploy in production========"
                      
                      script{
                            sh 'docker save $REPOSITORY_NAME/$IMAGE_NAME:${IMAGE_TAG} > $IMAGE_NAME.tar'
                            sshagent (credentials: [SSH_CREDENTIALS_ID]) {
                                sh """
                                echo "Uploading Docker image to Production EC2"
                                ssh ${PRODUCTION_USER}@${PRODUCTION_IP} '
                                    docker stop ${REPOSITORY_NAME}/${IMAGE_NAME}
                                    docker rm ${REPOSITORY_NAME}/${IMAGE_NAME}
                                    docker rmi ${REPOSITORY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                                    docker pull ${REPOSITORY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
                                docker run --name production_${IMAGE_NAME} -d -p 80:${PRODUCTION_HTTP_PORT} -e PORT=${PRODUCTION_HTTP_PORT} ${REPOSITORY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}'
                                """

                            }
                        
                        }
                  }
               }

                
            }

        }
