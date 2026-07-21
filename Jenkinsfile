pipeline {
    agent any

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
           stage('Test') {
              steps {
                  sh '''
                      echo "Test stage""
                      test -f index.html build/
                      npm test
                      echo "Test stage completed"
                  '''
              }
           }
    }
    post {
        always {
            junit 'test-result/junit.xml'
            echo 'Cleaning up...'
            cleanWs()
        }
    }}
}
