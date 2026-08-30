pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.${BUILD_ID}"
        AWS_DEFAULT_REGION = "eu-north-1"
        AWS_ECS_CLUSTER = "hollow-zebra-x0x9rb"
        AWS_ECS_SERVICE_PROD = "Learn-Jenkins-App-Service-Prod"
        AWS_DOCKER_REGISTRY = "781425929258.dkr.ecr.eu-north-1.amazonaws.com"
        AWS_ECS_TD_PROD = "learn-jenkins-app-task-definition-prod"
        LEARN_JENKINS_APP = "my-jenkins-app"
    }

    stages {
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

        stage('Build Docker image') {
            agent {
                dockerfile {
                    filename 'Dockerfile-aws-cli'
                    dir 'ci'
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                    reuseNode true
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_DOCKER_REGISTRY
                        docker build -t $AWS_DOCKER_REGISTRY/$LEARN_JENKINS_APP:$BUILD_ID .
                        docker push $AWS_DOCKER_REGISTRY/$LEARN_JENKINS_APP:$BUILD_ID
                    '''
                }
            }
        }

        stage('Deploy to AWS') {
            agent {
                dockerfile {
                    filename 'Dockerfile-aws-cli'
                    dir 'ci'
                    args "-u root --entrypoint=''"
                    reuseNode true
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        jq --arg IMAGE "$AWS_DOCKER_REGISTRY/$LEARN_JENKINS_APP:$BUILD_ID" '.containerDefinitions[0].image = $IMAGE' aws/task-definition-prod.json > td-final.json
                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://td-final.json | jq -r '.taskDefinition.revision')
                        echo $LATEST_TD_REVISION
                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE_PROD --task-definition $AWS_ECS_TD_PROD:$LATEST_TD_REVISION
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE_PROD
                    '''
                }
            }
        }
    }
}
