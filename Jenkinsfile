pipeline {
    agent any

    environment {
        BUILD_FILE_NAME = 'build/index.html'
        NETLIFY_SITE_ID = '09ae5c00-859c-4469-9026-c3d09edf0874'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_S3_BUCKET = 'learn-jenkins-2025-08-29'
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {

        stage('AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "-u root --entrypoint ''"
                    reuseNode true
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'jenkins_aws_cli_s3_admin', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        yum install -y jq
                        #aws s3 sync build s3://$AWS_S3_BUCKET/ --delete
                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition.json | jq '.taskDefinition.revision')
                        
                        aws ecs update-service \
                        --cluster learn-jenkins-nocturnal-horse-zo5n4u \
                        --service LearJenkinsApp-Prod-service-ye2462kt \
                        --task-definition LearJenkinsApp-TaskDefinition-Prod:$LATEST_TD_REVISION
                    '''
                }
            }
        }

        stage('Build') {
            // This is a comment about using Docker agent
            agent {
                docker {
                    image 'my-playwright'
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
        // stage('Run tests') {
        //     parallel {
        //         stage('Test') {
        //             agent {
        //                 docker {
        //                     image 'my-playwright'
        //                     reuseNode true
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //             echo "Test Stage"
        //             test -f $BUILD_FILE_NAME
        //             npm test
        //                 '''
        //             }
        //             post {
        //                 always {
        //                     junit 'jest-results/junit.xml'
        //                 }
        //             }
        //         }

        //         stage('E2E Tests') {
        //             agent {
        //                 docker {
        //                     image 'my-playwright'
        //                     reuseNode true
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //             serve -s build &
        //             sleep 10
        //             npx playwright test --reporter=html
        //                 '''
        //             }
        //             post {
        //                 always {
        //                     publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright_local Report', reportTitles: '', useWrapperFileDirectly: true])
        //                 }
        //             }
        //         }
        //     }
        // }
        // stage('Deploy staging') {
        //     agent {
        //         docker {
        //             image 'my-playwright'
        //             reuseNode true
        //         }
        //     }
        //     steps {
        //         sh '''
                    
        //             #npm install netlify-cli@20.1.1 jq
        //             #node_modules/.bin/netlify --version
        //             echo "Deploying to Netlify... Project_ID $NETLIFY_SITE_ID STAGING"
        //             netlify status
        //             netlify deploy --dir=build --json > deploy-output.json
        //             #node_modules/.bin/jq -r '.deploy_url' deploy-output.json
        //         '''
        //         script {
        //             env.deploy_url = sh(script: "jq -r '.deploy_url' deploy-output.json", returnStdout: true).trim()
        //         }
        //     }
        // }
        // stage(' E2E') {
        //     agent {
        //         docker {
        //             image 'my-playwright'
        //             reuseNode true
        //         }
        //     }
        //     environment {
        //         CI_ENVIRONMENT_URL = "${env.deploy_url}"
        //     }
        //     steps {
        //         sh '''
        //     npx playwright test --reporter=html
        //         '''
        //     }
        //     post {
        //         always {
        //             publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright_stage_E2E Report', reportTitles: '', useWrapperFileDirectly: true])
        //         }
        //     }
        // }
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
        // stage('Deploy production + E2E') {
        //     agent {
        //         docker {
        //             image 'my-playwright'
        //             reuseNode true
        //         }
        //     }
        //     environment {
        //         CI_ENVIRONMENT_URL = 'https://inspiring-medovik-94c869.netlify.app'
        //     }
        //     steps {
        //         sh '''
        //             echo "Deploying to Netlify... Project_ID $NETLIFY_SITE_ID"
        //             netlify deploy --dir=build --prod
        //             sleep 10
        //             npx playwright test --reporter=html
        //         '''
        //     }
        //     post {
        //         always {
        //             publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright_prod_E2E Report', reportTitles: '', useWrapperFileDirectly: true])
        //         }
        //     }
        // }
    }
}
