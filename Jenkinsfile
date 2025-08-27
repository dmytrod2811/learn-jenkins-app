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
    }
}
