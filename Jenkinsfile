pipeline {
    agent any

    environment {
        BUILD_FILE_NAME = 'build/index.html'
        NETLIFY_SITE_ID = '09ae5c00-859c-4469-9026-c3d09edf0874'
    }

    stages {
        stage('Build') {
            // This is a comment about using Docker agent
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
        stage('Run tests') {
            parallel {
                stage('Test') {
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
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E Tests') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.55.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                    npm install serve &
                    sleep 10
                    node_modules/.bin/serve -s build &
                    sleep 10
                    npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright_HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
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
                    
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version
                    echo "Deploying to Netlify... Project_ID $NETLIFY_SITE_ID"
                '''
            }
        }
    }
}
