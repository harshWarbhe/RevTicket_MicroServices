pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'harshwarbhe'
        PROJECT_NAME = 'revticket_microservices'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Maven Services') {
            parallel {
                stage('Build API Gateway') {
                    steps {
                        dir('Microservices-Backend/api-gateway') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build User Service') {
                    steps {
                        dir('Microservices-Backend/user-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Movie Service') {
                    steps {
                        dir('Microservices-Backend/movie-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Theater Service') {
                    steps {
                        dir('Microservices-Backend/theater-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Showtime Service') {
                    steps {
                        dir('Microservices-Backend/showtime-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Booking Service') {
                    steps {
                        dir('Microservices-Backend/booking-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Payment Service') {
                    steps {
                        dir('Microservices-Backend/payment-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Review Service') {
                    steps {
                        dir('Microservices-Backend/review-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Search Service') {
                    steps {
                        dir('Microservices-Backend/search-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Notification Service') {
                    steps {
                        dir('Microservices-Backend/notification-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Settings Service') {
                    steps {
                        dir('Microservices-Backend/settings-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Dashboard Service') {
                    steps {
                        dir('Microservices-Backend/dashboard-service') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Images') {
            parallel {
                stage('Build Frontend Image') {
                    steps {
                        dir('Frontend') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:latest"
                        }
                    }
                }
                stage('Build API Gateway Image') {
                    steps {
                        dir('Microservices-Backend/api-gateway') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:latest"
                        }
                    }
                }
                stage('Build User Service Image') {
                    steps {
                        dir('Microservices-Backend/user-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:latest"
                        }
                    }
                }
                stage('Build Movie Service Image') {
                    steps {
                        dir('Microservices-Backend/movie-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:latest"
                        }
                    }
                }
                stage('Build Theater Service Image') {
                    steps {
                        dir('Microservices-Backend/theater-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:latest"
                        }
                    }
                }
                stage('Build Showtime Service Image') {
                    steps {
                        dir('Microservices-Backend/showtime-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:latest"
                        }
                    }
                }
                stage('Build Booking Service Image') {
                    steps {
                        dir('Microservices-Backend/booking-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:latest"
                        }
                    }
                }
                stage('Build Payment Service Image') {
                    steps {
                        dir('Microservices-Backend/payment-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:latest"
                        }
                    }
                }
                stage('Build Review Service Image') {
                    steps {
                        dir('Microservices-Backend/review-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:latest"
                        }
                    }
                }
                stage('Build Search Service Image') {
                    steps {
                        dir('Microservices-Backend/search-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:latest"
                        }
                    }
                }
                stage('Build Notification Service Image') {
                    steps {
                        dir('Microservices-Backend/notification-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:latest"
                        }
                    }
                }
                stage('Build Settings Service Image') {
                    steps {
                        dir('Microservices-Backend/settings-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:latest"
                        }
                    }
                }
                stage('Build Dashboard Service Image') {
                    steps {
                        dir('Microservices-Backend/dashboard-service') {
                            sh "docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:latest"
                        }
                    }
                }
            }
        }
        
        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:latest"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:latest"
                }
            }
        }
    }
    
    post {
        always {
            sh "docker system prune -f"
        }
        success {
            echo 'Build and push to Docker Hub successful!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}