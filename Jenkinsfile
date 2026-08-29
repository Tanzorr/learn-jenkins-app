pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.${BUILD_ID}"
        AWS_DEFAULT_REGION = "eu-north-1"
    }

    stages {
       stage('Deploy to AWS') {
                         agent {
                              docker {
                                 image 'amazon/aws-cli'
                                 args "-u root --entrypoint=''"
                                 reuseNode true
                            }
                         }
                         steps {
                              withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                                       sh '''
                                           aws --version
                                           yum install jq -y
                                           LATES_TD_REVISION = $(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json | jq '.taksDefinition.revision)'
                                           echo $LATES_TD_REVISION
                                           aws ecs update-service --cluster hollow-zebra-x0x9rb --service Learn-Jenkins-App-Service-Prod --task-definition learn-jenkins-app-task-definition-prod:$LATES_TD_REVISION
                                          '''
                              }
                          }
                      }
       stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
    }
}
