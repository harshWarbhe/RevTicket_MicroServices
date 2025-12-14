
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'harshwarbhe'
        PROJECT_NAME = 'revticket_microservices'
        MAVEN_OPTS = '-Dmaven.repo.local=.m2/repository'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Tools') {
            steps {
                script {
                    // Check and setup Maven
                    sh '''
                        echo "Checking for Maven..."
                        if ! command -v mvn &> /dev/null; then
                            echo "Maven not found in PATH, checking common locations..."
                            if [ -f "/opt/homebrew/bin/mvn" ]; then
                                export PATH="/opt/homebrew/bin:$PATH"
                            elif [ -f "/usr/local/bin/mvn" ]; then
                                export PATH="/usr/local/bin:$PATH"
                            else
                                echo "Installing Maven..."
                                curl -O https://archive.apache.org/dist/maven/maven-3/3.9.0/binaries/apache-maven-3.9.0-bin.tar.gz
                                tar xzf apache-maven-3.9.0-bin.tar.gz
                                export PATH="$PWD/apache-maven-3.9.0/bin:$PATH"
                            fi
                        fi
                        mvn --version
                    '''
                    
                    // Check and setup Docker
                    sh '''
                        echo "Checking for Docker..."
                        if ! command -v docker &> /dev/null; then
                            echo "Docker not found in PATH, checking common locations..."
                            if [ -f "/usr/local/bin/docker" ]; then
                                export PATH="/usr/local/bin:$PATH"
                            elif [ -f "/opt/homebrew/bin/docker" ]; then
                                export PATH="/opt/homebrew/bin:$PATH"
                            fi
                        fi
                        docker --version || echo "Docker not available"
                    '''
                }
            }
        }
        
        stage('Build Maven Services') {
            parallel {
                stage('Build API Gateway') {
                    steps {
                        dir('Microservices-Backend/api-gateway') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build User Service') {
                    steps {
                        dir('Microservices-Backend/user-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Movie Service') {
                    steps {
                        dir('Microservices-Backend/movie-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Theater Service') {
                    steps {
                        dir('Microservices-Backend/theater-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Showtime Service') {
                    steps {
                        dir('Microservices-Backend/showtime-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Booking Service') {
                    steps {
                        dir('Microservices-Backend/booking-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Payment Service') {
                    steps {
                        dir('Microservices-Backend/payment-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Review Service') {
                    steps {
                        dir('Microservices-Backend/review-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Search Service') {
                    steps {
                        dir('Microservices-Backend/search-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Notification Service') {
                    steps {
                        dir('Microservices-Backend/notification-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Settings Service') {
                    steps {
                        dir('Microservices-Backend/settings-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
                stage('Build Dashboard Service') {
                    steps {
                        dir('Microservices-Backend/dashboard-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                mvn clean package -DskipTests
                            '''
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Images') {
            when {
                expression { 
                    return sh(script: 'command -v docker', returnStatus: true) == 0 ||
                           sh(script: '/usr/local/bin/docker --version', returnStatus: true) == 0 ||
                           sh(script: '/opt/homebrew/bin/docker --version', returnStatus: true) == 0
                }
            }
            parallel {
                stage('Build Frontend Image') {
                    steps {
                        dir('Frontend') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:latest
                            '''
                        }
                    }
                }
                stage('Build API Gateway Image') {
                    steps {
                        dir('Microservices-Backend/api-gateway') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:latest
                            '''
                        }
                    }
                }
                stage('Build User Service Image') {
                    steps {
                        dir('Microservices-Backend/user-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:latest
                            '''
                        }
                    }
                }
                stage('Build Movie Service Image') {
                    steps {
                        dir('Microservices-Backend/movie-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:latest
                            '''
                        }
                    }
                }
                stage('Build Theater Service Image') {
                    steps {
                        dir('Microservices-Backend/theater-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:latest
                            '''
                        }
                    }
                }
                stage('Build Showtime Service Image') {
                    steps {
                        dir('Microservices-Backend/showtime-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:latest
                            '''
                        }
                    }
                }
                stage('Build Booking Service Image') {
                    steps {
                        dir('Microservices-Backend/booking-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:latest
                            '''
                        }
                    }
                }
                stage('Build Payment Service Image') {
                    steps {
                        dir('Microservices-Backend/payment-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:latest
                            '''
                        }
                    }
                }
                stage('Build Review Service Image') {
                    steps {
                        dir('Microservices-Backend/review-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:latest
                            '''
                        }
                    }
                }
                stage('Build Search Service Image') {
                    steps {
                        dir('Microservices-Backend/search-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:latest
                            '''
                        }
                    }
                }
                stage('Build Notification Service Image') {
                    steps {
                        dir('Microservices-Backend/notification-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:latest
                            '''
                        }
                    }
                }
                stage('Build Settings Service Image') {
                    steps {
                        dir('Microservices-Backend/settings-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:latest
                            '''
                        }
                    }
                }
                stage('Build Dashboard Service Image') {
                    steps {
                        dir('Microservices-Backend/dashboard-service') {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                docker build -t ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:${BUILD_NUMBER} .
                                docker tag ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:${BUILD_NUMBER} ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:latest
                            '''
                        }
                    }
                }
            }
        }
        

        stage('Push Docker Images') {
            when {
                expression { 
                    return sh(script: 'command -v docker', returnStatus: true) == 0 ||
                           sh(script: '/usr/local/bin/docker --version', returnStatus: true) == 0 ||
                           sh(script: '/opt/homebrew/bin/docker --version', returnStatus: true) == 0
                }
            }
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                            sh '''
                                export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                                
                                echo "=== Docker Hub Push Started ==="
                                echo "Registry: ${DOCKER_REGISTRY}"
                                echo "Project: ${PROJECT_NAME}"
                                echo "Build Number: ${BUILD_NUMBER}"
                                
                                # Check Docker daemon connection
                                echo "Checking Docker daemon connection..."
                                docker info | head -n 5
                                
                                # Login to Docker Hub
                                echo "Logging into Docker Hub..."
                                echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                                
                                # Verify images exist
                                echo "Verifying built images..."
                                docker images | grep "${DOCKER_REGISTRY}/${PROJECT_NAME}" | head -n 10
                                
                                # Push all images with detailed logging
                                echo "Pushing images to Docker Hub..."
                                
                                # Frontend
                                echo "Pushing Frontend image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:latest
                                
                                # API Gateway
                                echo "Pushing API Gateway image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-api-gateway:latest
                                
                                # User Service
                                echo "Pushing User Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-user-service:latest
                                
                                # Movie Service
                                echo "Pushing Movie Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-movie-service:latest
                                
                                # Theater Service
                                echo "Pushing Theater Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-theater-service:latest
                                
                                # Showtime Service
                                echo "Pushing Showtime Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-showtime-service:latest
                                
                                # Booking Service
                                echo "Pushing Booking Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-booking-service:latest
                                
                                # Payment Service
                                echo "Pushing Payment Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-payment-service:latest
                                
                                # Review Service
                                echo "Pushing Review Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-review-service:latest
                                
                                # Search Service
                                echo "Pushing Search Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-search-service:latest
                                
                                # Notification Service
                                echo "Pushing Notification Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-notification-service:latest
                                
                                # Settings Service
                                echo "Pushing Settings Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-settings-service:latest
                                
                                # Dashboard Service
                                echo "Pushing Dashboard Service image..."
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:${BUILD_NUMBER}
                                docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}-dashboard-service:latest
                                
                                echo "=== Docker Hub Push Completed Successfully ==="
                                
                                # Logout from Docker Hub
                                docker logout
                                
                            '''
                        }
                    } catch (Exception e) {
                        echo "Docker push failed: ${e.getMessage()}"
                        echo "Build will continue without Docker push..."
                        sh '''
                            export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                            docker logout || echo "Docker logout skipped"
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                try {
                    sh '''
                        export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
                        docker system prune -f || echo "Docker cleanup skipped"
                    '''
                } catch (Exception e) {
                    echo "Docker cleanup failed: ${e.getMessage()}"
                }
            }
        }
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}
