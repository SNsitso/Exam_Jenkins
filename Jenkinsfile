pipeline {
    agent any
    
    environment {
        // Environment variables
        DOCKER_REGISTRY = 'snsitso'
        BUILD_NUMBER_TAG = "${env.BUILD_NUMBER}"
        GIT_BRANCH_NAME = "${env.BRANCH_NAME}"
    }

    stages {
        stage('Cloning Repository') {
            steps {
                git url: 'https://github.com/SNsitso/Exam_Jenkins.git', branch: 'master'
            }
        }

        stage('Build Cast Service') {
            steps {
                script {
                    echo "Building Cast Service..."
                    sh """
                        cd cast-service
                        docker build -t ${DOCKER_REGISTRY}/cast-service:${BUILD_NUMBER_TAG} .
                        docker tag ${DOCKER_REGISTRY}/cast-service:${BUILD_NUMBER_TAG} ${DOCKER_REGISTRY}/cast-service:latest
                    """
                }
            }
        }

        stage('Build Movie Service') {
            steps {
                script {
                    echo "Building Movie Service..."
                    sh """
                        cd movie-service
                        docker build -t ${DOCKER_REGISTRY}/movie-service:${BUILD_NUMBER_TAG} .
                        docker tag ${DOCKER_REGISTRY}/movie-service:${BUILD_NUMBER_TAG} ${DOCKER_REGISTRY}/movie-service:latest
                    """
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    echo "Running application tests..."
                    sh """
                        # Test if services start correctly
                        docker run --rm -d --name cast-test ${DOCKER_REGISTRY}/cast-service:${BUILD_NUMBER_TAG}
                        sleep 5
                        docker stop cast-test || true
                        
                        docker run --rm -d --name movie-test ${DOCKER_REGISTRY}/movie-service:${BUILD_NUMBER_TAG}
                        sleep 5
                        docker stop movie-test || true
                        
                        echo "Basic smoke tests passed!"
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            
                            # Push Cast Service
                            docker push ${DOCKER_REGISTRY}/cast-service:${BUILD_NUMBER_TAG}
                            docker push ${DOCKER_REGISTRY}/cast-service:latest
                            
                            # Push Movie Service
                            docker push ${DOCKER_REGISTRY}/movie-service:${BUILD_NUMBER_TAG}
                            docker push ${DOCKER_REGISTRY}/movie-service:latest
                            
                            echo "All images pushed successfully!"
                        """
                    }
                }
            }
        }

        stage('Deploy to Development') {
            steps {
                script {
                    echo "Deploying to Development environment..."
                    sh """
                        # Create namespace if not exists
                        kubectl create namespace dev || echo "Namespace dev already exists"
                        
                        # Deploy using Helm
                        helm upgrade --install microservices-dev ./charts \\
                            --namespace dev \\
                            --set image.castService.repository=${DOCKER_REGISTRY}/cast-service \\
                            --set image.castService.tag=${BUILD_NUMBER_TAG} \\
                            --set image.movieService.repository=${DOCKER_REGISTRY}/movie-service \\
                            --set image.movieService.tag=${BUILD_NUMBER_TAG} \\
                            --set environment=dev
                    """
                }
            }
        }

        stage('Deploy to QA') {
            when {
                anyOf {
                    branch 'master'
                    branch 'develop'
                }
            }
            steps {
                script {
                    echo "Deploying to QA environment..."
                    sh """
                        # Create namespace if not exists
                        kubectl create namespace qa || echo "Namespace qa already exists"
                        
                        # Deploy using Helm
                        helm upgrade --install microservices-qa ./charts \\
                            --namespace qa \\
                            --set image.castService.repository=${DOCKER_REGISTRY}/cast-service \\
                            --set image.castService.tag=${BUILD_NUMBER_TAG} \\
                            --set image.movieService.repository=${DOCKER_REGISTRY}/movie-service \\
                            --set image.movieService.tag=${BUILD_NUMBER_TAG} \\
                            --set environment=qa
                    """
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'master'
            }
            steps {
                script {
                    echo "Deploying to Staging environment..."
                    sh """
                        # Create namespace if not exists
                        kubectl create namespace staging || echo "Namespace staging already exists"
                        
                        # Deploy using Helm
                        helm upgrade --install microservices-staging ./charts \\
                            --namespace staging \\
                            --set image.castService.repository=${DOCKER_REGISTRY}/cast-service \\
                            --set image.castService.tag=${BUILD_NUMBER_TAG} \\
                            --set image.movieService.repository=${DOCKER_REGISTRY}/movie-service \\
                            --set image.movieService.tag=${BUILD_NUMBER_TAG} \\
                            --set environment=staging
                    """
                }
            }
        }

        stage('Deploy to Production') {
            when {
                allOf {
                    branch 'master'
                    expression { return params.DEPLOY_TO_PROD == true }
                }
            }
            steps {
                script {
                    echo "Deploying to Production environment..."
                    sh """
                        # Create namespace if not exists
                        kubectl create namespace prod || echo "Namespace prod already exists"
                        
                        # Deploy using Helm
                        helm upgrade --install microservices-prod ./charts \\
                            --namespace prod \\
                            --set image.castService.repository=${DOCKER_REGISTRY}/cast-service \\
                            --set image.castService.tag=${BUILD_NUMBER_TAG} \\
                            --set image.movieService.repository=${DOCKER_REGISTRY}/movie-service \\
                            --set image.movieService.tag=${BUILD_NUMBER_TAG} \\
                            --set environment=prod \\
                            --set replicaCount=3
                    """
                }
            }
        }
    }

    parameters {
        booleanParam(name: 'DEPLOY_TO_PROD', defaultValue: false, description: 'Deploy to Production (Manual trigger only)')
    }

    post {
        always {
            echo "Pipeline completed!"
            // Clean up local images to save space
            sh """
                docker rmi ${DOCKER_REGISTRY}/cast-service:${BUILD_NUMBER_TAG} || true
                docker rmi ${DOCKER_REGISTRY}/movie-service:${BUILD_NUMBER_TAG} || true
            """
        }
        success {
            echo "Pipeline executed successfully!"
        }
        failure {
            echo "Pipeline failed! Please check the logs."
        }
    }
}
