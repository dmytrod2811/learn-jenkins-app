pipeline {
    agent any

    environment {
        BUILD_FILE_NAME = 'build/index.html'
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
                    node -v
                    npm -v
                    echo "Building inside a Docker container..."
                    npm ci
                    npm run build
                    ls -la
                    ls -la build
                '''
            }
        }
        stage('test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Test Stage"
                    test -f $BUILD_FILE_NAME
                    npm test
                '''
            }
        }
    }
}
