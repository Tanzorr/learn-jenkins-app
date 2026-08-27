pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'da00dfe9-8c93-4ec5-89f6-d91388ac75d7'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.${BUILD_ID}"
    }

    stages {
       stage('AWS') {
           agent {
                docker {
                   image 'amazon/aws-cli'
                   args " --entrypoint=''"
              }
           }
           steps {
                sh '''
                   aws --version
                '''
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

        stage('Tests') {
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            #test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'my-playwright-image'
                            reuseNode true
                        }
                    }

                    steps {
                        sh '''
                            npx playwright test --reporter=html
                        '''
                    }

                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
        stage('Deploy staging') {
            agent {
                docker {
                    image 'my-playwright-image'
                    reuseNode true
                }
            }

            steps {
                sh '''
                    netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --json | tee deploy-output.json
                    export CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy-output.json)
                    echo "Staging URL: $CI_ENVIRONMENT_URL"
                    npx playwright test --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Stage E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }

             stage('Deploy prod') {
            agent {
                docker {
                    image 'my-playwright-image'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://heartfelt-kashata-2ab763.netlify.app'
            }

            steps {
                sh '''
                    netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --prod
                    npx playwright test --reporter=html
                '''
            }

            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
}
