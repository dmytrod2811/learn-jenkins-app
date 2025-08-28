pipeline {
    agent any

    environment {
        BUILD_FILE_NAME = 'build/index.html'
        NETLIFY_SITE_ID = '09ae5c00-859c-4469-9026-c3d09edf0874'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
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
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright_local Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
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
                    
                    npm install netlify-cli@20.1.1 node-jq
                    node_modules/.bin/netlify --version
                    echo "Deploying to Netlify... Project_ID $NETLIFY_SITE_ID STAGING"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                    #node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json
                '''
                script {
                    env.deploy_url = sh(script: "node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json", returnStdout: true).trim()
                }
            }
        }
        stage(' E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.55.0-jammy'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = "${env.deploy_url}"
            }
            steps {
                sh '''
            npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright_stage_E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
        // stage('Aproval') {
        //     steps {
        //         timeout(time: 1, unit: 'MINUTES') {
        //             input message: 'Approve Deployment?', ok: 'Deploy'
        //         }
        //     }
        // }
        // stage('Deploy production') {
        //     agent {
        //         docker {
        //             image 'node:18-alpine'
        //             reuseNode true
        //         }
        //     }
        //     steps {
        //         sh '''

        //             npm install netlify-cli@20.1.1
        //             node_modules/.bin/netlify --version
        //             echo "Deploying to Netlify... Project_ID $NETLIFY_SITE_ID"
        //             node_modules/.bin/netlify status
        //             node_modules/.bin/netlify deploy --dir=build --prod
        //             #just to check, comment out if not needed
        //         '''
        //     }
        // }
        stage('Deploy production + E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.55.0-jammy'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://inspiring-medovik-94c869.netlify.app'
            }
            steps {
                sh '''
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version
                    echo "Deploying to Netlify... Project_ID $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                    sleep 10
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright_Prod_E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }
    }
}
