pipeline {
    
    agent any
    
    environment {
        DOCKER_HOST="unix://\$(pwd)/docker.sock"
        STAGE_INSTANCE="ubuntu@172.31.33.234"
    }

    stages {

        stage('Setup SSH tunnel') {
            steps {
                script {
                    sh "ssh -nNT -L \$(pwd)/docker.sock:/var/run/docker.sock ${STAGE_INSTANCE} & echo \$! > /tmp/tunnel.pid"
                    // sometimes it's not enough time to make a tunnel, add sleep
                    sleep 5
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh "DOCKER_HOST=${DOCKER_HOST} docker ps -a"
                }
            }
        }
    }

    post {
        always {
            script {
                sh "pkill -F /tmp/tunnel.pid"
                sh "rm -rf /var/lib/jenkins/workspace/docker-pipeline/docker.sock" // added to fix unix_listener: cannot bind to path /var/lib/jenkins/workspace/docker-pipeline/docker.sock: Address already in use
            }
        }
    }
}


