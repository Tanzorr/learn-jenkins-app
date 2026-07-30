pipeline {
    agent any

    environment {
     NETLIFY_PROJECT_ID = 'da00dfe9-8c93-4ec5-89f6-d91388ac75d7'
     NETLIFY_AUTH_TOKEN = credentials('netlify_tocken')
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

        stage('Tests') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            echo "Test stage"
                            test -f build/index.html
                            npm test
                            echo "Test stage completed"
                        '''
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve@13
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html --output=e2e-results
                        '''
                    }
                }
            }
        }

        stage('Deploy') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                           npm install netlify-cli
                           node_modules/.bin/netlify --version
                           echo "Deploying to Netlify Project ID: $NETLIFY_PROJECT_ID"
                           node_modules/.bin/netlify status
                           node_modules/.bin/netlify deploy
                        '''
                    }
                }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'test-results/junit.xml'
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
}
