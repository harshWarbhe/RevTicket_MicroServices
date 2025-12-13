pipeline {
    agent any
    
    environment {
        DOCKER_REPO = "harshwarbhe"
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
        BUILD_VERSION = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Test') {
            parallel {
                stage('Backend Test') {
                    steps {
                        dir('Microservices-Backend') {
                            sh 'mvn clean test'
                        }
                    }
                }
                stage('Frontend Test') {
                    steps {
                        dir('Frontend') {
                            sh 'npm ci && npm run test -- --watch=false --browsers=ChromeHeadless'
                        }
                    }
                }
            }
        }
        
        stage('Build') {
            parallel {
                stage('Backend Build') {
                    steps {
                        dir('Microservices-Backend') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Frontend Build') {
                    steps {
                        dir('Frontend') {
                            sh 'npm run build --prod'
                        }
                    }
                }
            }
        }
        
        stage('Create Docker Images') {
            steps {
                script {
                    def services = [
                        'api-gateway', 'user-service', 'movie-service', 'theater-service',
                        'showtime-service', 'booking-service', 'payment-service', 'review-service',
                        'search-service', 'notification-service', 'settings-service', 'dashboard-service'
                    ]
                    
                    services.each { service ->
                        sh "docker build -t ${DOCKER_REPO}/${service}:${BUILD_VERSION} ./Microservices-Backend/${service}"
                        sh "docker tag ${DOCKER_REPO}/${service}:${BUILD_VERSION} ${DOCKER_REPO}/${service}:latest"
                    }
                    
                    sh "docker build -t ${DOCKER_REPO}/frontend:${BUILD_VERSION} ./Frontend"
                    sh "docker tag ${DOCKER_REPO}/frontend:${BUILD_VERSION} ${DOCKER_REPO}/frontend:latest"
                }
            }
        }
        
        stage('Push To DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://docker.io', "${DOCKER_CREDENTIALS_ID}") {
                        def services = [
                            'api-gateway', 'user-service', 'movie-service', 'theater-service',
                            'showtime-service', 'booking-service', 'payment-service', 'review-service',
                            'search-service', 'notification-service', 'settings-service', 'dashboard-service',
                            'frontend'
                        ]
                        
                        services.each { service ->
                            sh "docker push ${DOCKER_REPO}/${service}:${BUILD_VERSION}"
                            sh "docker push ${DOCKER_REPO}/${service}:latest"
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker system prune -f'
            cleanWs()
        }
    }
}