pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = env.DOCKER_REGISTRY ?: 'docker.io'
        DOCKER_REPO = env.DOCKER_REPO ?: 'harshwarbhe'
        DOCKER_CREDENTIALS_ID = env.DOCKER_CREDENTIALS_ID ?: 'harshwarbhe'


        MYSQL_ROOT_PASSWORD = credentials('mysql-root-password')
        JWT_SECRET = credentials('jwt-secret')
        RAZORPAY_KEY_ID = credentials('razorpay-key-id')
        RAZORPAY_KEY_SECRET = credentials('razorpay-key-secret')
        MAIL_USERNAME = credentials('mail-username')
        MAIL_PASSWORD = credentials('mail-password')
        
    }
    
    tools {
        maven 'Maven'
        jdk 'JDK-17'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.BUILD_VERSION = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
                }
            }
        }
        
        stage('Environment Setup') {
            steps {
                script {
                    writeFile file: '.env', text: """
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DATABASE=revticket_db
JWT_SECRET=${JWT_SECRET}
RAZORPAY_KEY_ID=${RAZORPAY_KEY_ID}
RAZORPAY_KEY_SECRET=${RAZORPAY_KEY_SECRET}
MAIL_USERNAME=${MAIL_USERNAME}
MAIL_PASSWORD=${MAIL_PASSWORD}
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
FRONTEND_URL=http://localhost:4200
API_GATEWAY_URL=http://localhost:8080
"""
                }
            }
        }
        
        stage('Setup Databases') {
            steps {
                sh '''
                    # Start MySQL container
                    docker run -d --name test-mysql \
                        -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
                        -e MYSQL_DATABASE=revticket_db \
                        -p 3307:3306 \
                        mysql:8.0
                    
                    # Start MongoDB container
                    docker run -d --name test-mongodb \
                        -p 27018:27017 \
                        mongo:8.0
                    
                    # Wait for databases to be ready
                    sleep 30
                '''
            }
        }
        
        stage('Install Node.js') {
            steps {
                sh '''
                    # Install Node.js 18 if not present
                    if ! command -v node &> /dev/null || [[ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 18 ]]; then
                        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                    fi
                    node --version
                    npm --version
                '''
            }
        }
        
        stage('Build Backend Services') {
            steps {
                sh 'mvn clean compile -DskipTests'
            }
        }
        
        stage('Test Backend Services') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    publishTestResults testResultsPattern: '*/target/surefire-reports/*.xml'
                }
            }
        }
        

        
        stage('Build Frontend') {
            when {
                expression { fileExists('Frontend/package.json') }
            }
            steps {
                dir('Frontend') {
                    sh 'npm ci'
                    sh 'npm run build --prod'
                }
            }
        }
        
        stage('Package Services') {
            parallel {
                stage('Package Backend') {
                    steps {
                        sh 'mvn clean package -DskipTests'
                    }
                }
                stage('Package Frontend') {
                    when {
                        expression { fileExists('Frontend/package.json') }
                    }
                    steps {
                        dir('Frontend') {
                            sh 'npm run build --prod'
                        }
                    }
                }
            }
        }
        
        stage('Setup Docker Buildx') {
            steps {
                sh '''
                    # Setup buildx for multi-platform builds
                    docker buildx create --name multiarch --use --bootstrap || true
                    docker buildx inspect --bootstrap
                    
                    # Login to Docker registry
                    echo "Logging into Docker registry..."
                '''
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                        sh 'echo "Docker login successful"'
                    }
                }
            }
        }
        
        stage('Build Docker Images') {
            parallel {
                stage('Build API Gateway Image') {
                    steps {
                        script {
                            // Build for local use first (AMD64)
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f api-gateway/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/api-gateway:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/api-gateway:latest \
                                    --load api-gateway
                            """
                            
                            // Build multi-platform and push to registry
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f api-gateway/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/api-gateway:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/api-gateway:latest \
                                        --push api-gateway
                                """
                            }
                        }
                    }
                }
                stage('Build User Service Image') {
                    steps {
                        script {
                            // Build for local use first (AMD64)
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f user-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/user-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/user-service:latest \
                                    --load user-service
                            """
                            
                            // Build multi-platform and push to registry
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f user-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/user-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/user-service:latest \
                                        --push user-service
                                """
                            }
                        }
                    }
                }
                stage('Build Movie Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/movie-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/movie-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/movie-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/movie-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/movie-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/movie-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Theater Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/theater-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/theater-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/theater-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/theater-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/theater-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/theater-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Showtime Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/showtime-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/showtime-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/showtime-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/showtime-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/showtime-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/showtime-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Booking Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/booking-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/booking-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/booking-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/booking-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/booking-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/booking-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Payment Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/payment-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/payment-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/payment-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/payment-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/payment-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/payment-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Review Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/review-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/review-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/review-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/review-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/review-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/review-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Search Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/search-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/search-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/search-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/search-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/search-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/search-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Notification Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/notification-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/notification-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/notification-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/notification-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/notification-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/notification-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Settings Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/settings-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/settings-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/settings-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/settings-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/settings-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/settings-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Dashboard Service Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Microservices-Backend/dashboard-service/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/dashboard-service:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/dashboard-service:latest \
                                    --load Microservices-Backend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Microservices-Backend/dashboard-service/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/dashboard-service:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/dashboard-service:latest \
                                        --push Microservices-Backend
                                """
                            }
                        }
                    }
                }
                stage('Build Frontend Image') {
                    steps {
                        script {
                            sh """
                                docker buildx build --platform linux/amd64 \
                                    -f Frontend/Dockerfile \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION} \
                                    -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:latest \
                                    --load Frontend
                            """
                            
                            docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                                sh """
                                    docker buildx build --platform linux/amd64,linux/arm64 \
                                        -f Frontend/Dockerfile \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION} \
                                        -t ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:latest \
                                        --push Frontend
                                """
                            }
                        }
                    }
                }
            }
        }
        
        stage('Security Scan') {
            parallel {
                stage('Trivy Scan') {
                    steps {
                        sh """
                            # Scan critical services
                            trivy image --format json --output trivy-api-gateway.json ${DOCKER_REGISTRY}/${DOCKER_REPO}/api-gateway:${BUILD_VERSION}
                            trivy image --format json --output trivy-user-service.json ${DOCKER_REGISTRY}/${DOCKER_REPO}/user-service:${BUILD_VERSION}
                            trivy image --format json --output trivy-payment-service.json ${DOCKER_REGISTRY}/${DOCKER_REPO}/payment-service:${BUILD_VERSION}
                            trivy image --format json --output trivy-frontend.json ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION}
                        """
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'trivy-*.json', fingerprint: true
                        }
                    }
                }
                stage('OWASP Dependency Check') {
                    steps {
                        dir('Microservices-Backend') {
                            sh 'mvn org.owasp:dependency-check-maven:check'
                        }
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'Microservices-Backend/target',
                                reportFiles: 'dependency-check-report.html',
                                reportName: 'OWASP Dependency Check Report'
                            ])
                        }
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    sh """
                        # Update docker-compose with new image versions
                        sed -i 's|image: .*harshwarbhe/api-gateway.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/api-gateway:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/user-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/user-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/movie-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/movie-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/theater-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/theater-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/showtime-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/showtime-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/booking-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/booking-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/payment-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/payment-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/review-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/review-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/search-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/search-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/notification-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/notification-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/settings-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/settings-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/dashboard-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/dashboard-service:${BUILD_VERSION}|g' docker-compose.yml
                        sed -i 's|image: .*harshwarbhe/frontend.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION}|g' docker-compose.yml
                        
                        # Deploy with Docker Compose
                        docker-compose down || true
                        docker-compose pull
                        docker-compose up -d
                        
                        # Wait for services to be ready
                        sleep 30
                    """
                }
            }
        }
        
        stage('Integration Tests') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    sh '''
                        # Wait for services to be ready
                        sleep 60
                        
                        # Run integration tests
                        cd Microservices-Backend
                        mvn test -Dtest=**/*IntegrationTest
                    '''
                }
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'Microservices-Backend/*/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to Production?', ok: 'Deploy'
                script {
                    sh """
                        # Create production docker-compose file
                        cp docker-compose.yml docker-compose.prod.yml
                        
                        # Update production compose with new image versions
                        sed -i 's|image: .*harshwarbhe/api-gateway.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/api-gateway:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/user-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/user-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/movie-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/movie-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/theater-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/theater-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/showtime-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/showtime-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/booking-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/booking-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/payment-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/payment-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/review-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/review-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/search-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/search-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/notification-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/notification-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/settings-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/settings-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/dashboard-service.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/dashboard-service:${BUILD_VERSION}|g' docker-compose.prod.yml
                        sed -i 's|image: .*harshwarbhe/frontend.*|image: ${DOCKER_REGISTRY}/${DOCKER_REPO}/frontend:${BUILD_VERSION}|g' docker-compose.prod.yml
                        
                        # Deploy production environment
                        docker-compose -f docker-compose.prod.yml down || true
                        docker-compose -f docker-compose.prod.yml pull
                        docker-compose -f docker-compose.prod.yml up -d
                        
                        # Wait for services to be ready
                        sleep 60
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sh '''
                        # Health check endpoints for all services
                        echo "Checking service health..."
                        
                        # Wait for services to be fully ready
                        sleep 30
                        
                        # Check each service health endpoint
                        for port in 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8091; do
                            echo "Checking service on port $port..."
                            curl -f http://localhost:$port/actuator/health || echo "Service on port $port not ready"
                        done
                        
                        # Check frontend
                        curl -f http://localhost:4200 || echo "Frontend not ready"
                        
                        # Show running containers
                        docker-compose ps
                    '''
                }
            }
        }
    }
    
    post {
        always {
            sh '''
                # Cleanup test databases
                docker stop test-mysql test-mongodb || true
                docker rm test-mysql test-mongodb || true
            '''
            cleanWs()
        }
        success {
            emailext (
                subject: "✅ RevTicket Build Success - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    Build successful for RevTicket Microservices!
                    
                    Build: ${env.BUILD_NUMBER}
                    Version: ${BUILD_VERSION}
                    Branch: ${env.BRANCH_NAME}
                    Commit: ${env.GIT_COMMIT}
                    
                    View build: ${env.BUILD_URL}
                """,
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
        failure {
            emailext (
                subject: "❌ RevTicket Build Failed - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    Build failed for RevTicket Microservices!
                    
                    Build: ${env.BUILD_NUMBER}
                    Branch: ${env.BRANCH_NAME}
                    Commit: ${env.GIT_COMMIT}
                    
                    View build: ${env.BUILD_URL}
                    Console: ${env.BUILD_URL}console
                """,
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}