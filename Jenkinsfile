pipeline{
          environment{
              IMAGE_NAME = "alpinehellowolrd"
              IMAGE_TAG = "latest"
              STAGING = "coulibaltech-staging"
              PRODUCTION = "coulibaltech-production"
              REPOSITORY_NAME = "coulibalytech"
          }
          agent none
          stages{
              stage("Build image"){
                  agent any
                  steps{
                      echo "========executing Build image========"
                      script{
                          sh 'docker build -t $REPOSITORY_NAME/$IMAGE_NAME:$IMAGE_TAG .'
                      }
                  }
                  
              }
              stage("Run container based on builded image"){
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
              stage("Test image"){
                  agent any
                  steps{
                      echo "========executing Test image========"
                      script{
                          sh 'curl http://172.17.0.1 | grep -q "Hello world!"'
                      }
                  }
                  
              }
              stage("Clean container"){
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
              stage("Push image in staging and deploy it"){
                  when{
                      expression {GIT_BRANCH == 'origin/master'}
                  }
                  agent any
                  environment {
                      HEREOKU_API_KEY = credentials('heroku_api_key')
                      }

                  steps{
                      echo "========executing Push image in staging and deploy it========"
                      script{
                        sh '''
                        heroku container:login
                        heroku create $STAGING || echo "project already exist"
                        heroku container:push -a $STAGING web
                        heroku container:release -a $STAGING web
                          '''
                      }
                  }
              }
              stage("Push image in production and deploy it"){
                  when{
                      expression {GIT_BRANCH == 'origin/master'}
                  }
                  agent any
                  environment {
                      HEROKU_API_KEY = credentials('heroku_api_key')
                      }

                  steps{
                      echo "========executing Push image in production and deploy it========"
                      script{
                        sh '''
                        sudo apt install -y nodejs
                        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
                        sudo apt install -y nodejs
                        npm uninstall -g heroku
                        npm install -g heroku
                        heroku version
                        heroku container:login
                        heroku create $PRODUCTION || echo "project already exist"
                        heroku container:push -a $PRODUCTION web
                        heroku container:release -a $PRODUCTION web
                          '''
                      }
                  }
              }
          }
}
