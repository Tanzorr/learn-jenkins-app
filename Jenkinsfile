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

        stage('Deploy staging') {
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
                    node_modules/.bin/netlify deploy --auth=$NETLIFY_AUTH_TOKEN --site=$NETLIFY_PROJECT_ID --dir=build --no-build --json > deploy-output.json
                    cat deploy-output.json
                '''
                script {
                    def jsonText = readFile('deploy-output.json')
                    def deployOutput = new groovy.json.JsonSlurper().parseText(jsonText)
                    env.NETLIFY_SITE_URL = deployOutput.url
                    echo "Deployed to: ${env.NETLIFY_SITE_URL}"
                }
            }
        }

        stage('Deploy production') {
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
                            node_modules/.bin/netlify deploy --auth=$NETLIFY_AUTH_TOKEN --site=$NETLIFY_PROJECT_ID --dir=build --prod --no-build --json > deploy-output.json
                            cat deploy-output.json
                        '''
                        script {
                            def jsonText = readFile('deploy-output.json')
                            def deployOutput = new groovy.json.JsonSlurper().parseText(jsonText)
                            env.NETLIFY_SITE_URL = deployOutput.url
                            echo "Deployed to: ${env.NETLIFY_SITE_URL}"
                        }
                    }
                }

        stage('Prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "${NETLIFY_SITE_URL}"
            }
            steps {
                sh '''
                    npx playwright test --reporter=html --output=e2e-results
                '''
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'test-results/junit.xml'
            publishHTML([allowMissing: true, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
}
