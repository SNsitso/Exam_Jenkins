pipeline {
    agent any

    stages {
        stage('Cloning Repository') {
            steps {
                git url: 'https://github.com/SNsitso/Exam_Jenkins.git', branch: 'master'
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    sh 'docker build -t snsitso/exam-app:latest .'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push snsitso/exam-app:latest
                        """
                    }
                }
            }
        }
    }
}
