def registry = '753743851231.dkr.ecr.us-east-2.amazonaws.com'
def reponame = 'dvsp-javappimage'

pipeline {
    agent {
        node {
            label 'node'
        }
    }
    tools {
        maven 'maven3'
    }

    parameters { string(name: 'DEPLOY_TO', defaultValue: 'staging', description: '') }

    stages {
        stage('Building warfile') { 
            steps {
                sh 'mvn -B -DskipTests clean package' 
            }
        }

        stage('Unit Tests') { 
            steps {
                sh 'mvn test' 
            }
        }

        stage('Build Image') {
            steps {
                script{
                    image = reponame + ":" + env.BUILD_ID // prepares tag name for the image
                    javapp = docker.build(image)                 
                }                
            }
        }
       
        stage('Scan Image'){
            steps{                
                sh "trivy image ${reponame}:${env.BUILD_ID}"
            }
        }

        stage('Push Image') {
            steps {
                script{
                    docker.withRegistry('https://' + registry, 'ecr:us-east-2:awscred') {                                             
                        javapp.push()                          
                    }                                    
                }                
            }
            post {
                always {
                    sh "docker rmi ${reponame}:${env.BUILD_ID}"
                }           
            }
        }

        stage('Deploy Image') {            
            steps {
                script{

                    if (params.DEPLOY_TO  == 'staging') {

                            docker.withRegistry('https://' + registry, 'ecr:us-east-2:awscred') { 
                            javapp.pull()  
                            sh 'docker rm -f javapp-staging || true'                      
                            sh "docker run --name javapp-staging -p 7000:8080 -d ${registry}/${reponame}:${env.BUILD_ID}"                                          
                        
                        }                              
                    } 

                    if (params.DEPLOY_TO  == 'production') {

                            docker.withRegistry('https://' + registry, 'ecr:us-east-2:awscred') { 
                            javapp.pull()  
                            sh 'docker rm -f javapp-production || true'                      
                            sh "docker run --name javapp-production -p 8000:8080 -d ${registry}/${reponame}:${env.BUILD_ID}"                                          
                        
                        }                              
                    }                       
                }                
            }
        }
    }  
}


