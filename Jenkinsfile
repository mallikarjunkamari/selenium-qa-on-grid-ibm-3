pipeline {
    agent any

    tools {
        maven 'Maven-3.9'
        jdk 'JDK-17'
    }

    environment {
        BASE_URL = 'https://the-internet.herokuapp.com'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(
            numToKeepStr: '20',
            artifactNumToKeepStr: '10'
        ))
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo "Running tests against ${BASE_URL}"

                sh """
                    mvn clean test \
                    -Dbase.url=${BASE_URL} \
                    -Dmaven.test.failure.ignore=false
                """
            }

            post {
                always {
                    echo 'Publishing JUnit results...'

                    junit(
                        allowEmptyResults: true,
                        testResults: 'target/surefire-reports/*.xml'
                    )
                }
            }
        }

        stage('Generate HTML Report') {
            steps {
                echo 'Generating Maven Surefire report...'

                sh '''
                    mvn surefire-report:report
                '''
            }
        }

        stage('Publish Report') {
            steps {
                echo 'Publishing HTML report...'

                publishHTML([
                    reportDir: 'target/site',
                    reportFiles: 'surefire-report.html',
                    reportName: 'Automation Test Report',
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    allowMissing: true
                ])
            }
        }
    }

    post {

        success {
            echo '✅ All tests green'
        }

        failure {
            echo '❌ Test execution failed'
        }

        unstable {
            echo '⚠️ Some tests failed'
        }

        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
    }
}