# Jenkins Setup Guide for RevTicket Microservices

## Prerequisites

1. **Jenkins Server** with the following plugins:
   - Docker Pipeline
   - SSH Agent
   - Credentials Binding
   - Pipeline

2. **Docker Hub Account** for image registry

3. **AWS EC2 Instance** (Ubuntu 20.04 LTS recommended)

## Step 1: Configure Jenkins Credentials

### 1.1 Docker Hub Credentials
1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Add new Username/Password credential:
   - ID: `dockerhub-credentials`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password

### 1.2 EC2 SSH Key
1. Add new SSH Username with private key:
   - ID: `ec2-ssh-key`
   - Username: `ubuntu`
   - Private Key: Your EC2 instance private key (.pem file content)

## Step 2: Prepare EC2 Instance

### 2.1 Launch EC2 Instance
- Instance Type: t3.large or larger (minimum 4GB RAM)
- Security Group: Allow ports 22, 80, 443, 4200, 8080, 8500
- Storage: 20GB or more

### 2.2 Run Setup Script
```bash
# Copy and run the setup script on EC2
scp -i your-key.pem ec2-setup.sh ubuntu@your-ec2-ip:/home/ubuntu/
ssh -i your-key.pem ubuntu@your-ec2-ip
chmod +x ec2-setup.sh
./ec2-setup.sh
```

### 2.3 Configure Environment Variables
```bash
# Edit the .env file with your actual values
nano /home/ubuntu/revticket/.env
```

## Step 3: Update Jenkins Pipeline Configuration

### 3.1 Update Jenkinsfile Environment Variables
Edit the `Jenkinsfile` and update:
```groovy
environment {
    DOCKER_REGISTRY = 'your-actual-dockerhub-username'
    AWS_REGION = 'your-aws-region'
    EC2_HOST = 'your-ec2-public-ip'
    EC2_USER = 'ubuntu'
    PROJECT_NAME = 'revticket'
}
```

### 3.2 Update Docker Compose Production File
Edit `docker-compose.prod.yml` and replace:
- `your-dockerhub-username` with your actual Docker Hub username

## Step 4: Create Jenkins Pipeline Job

1. **New Item** → **Pipeline**
2. **Pipeline Definition**: Pipeline script from SCM
3. **SCM**: Git
4. **Repository URL**: Your Git repository URL
5. **Script Path**: `Jenkinsfile`

## Step 5: Build and Deploy

### 5.1 Trigger Build
- Click "Build Now" in Jenkins
- Monitor the pipeline execution

### 5.2 Verify Deployment
After successful deployment, verify services:
```bash
# Check running containers
docker ps

# Check service health
curl http://your-ec2-ip:8080/actuator/health

# Access application
http://your-ec2-ip:4200
```

## Step 6: Configure Domain (Optional)

### 6.1 Set up Load Balancer
- Create Application Load Balancer in AWS
- Configure target groups for ports 4200 and 8080
- Set up health checks

### 6.2 Configure SSL Certificate
- Use AWS Certificate Manager
- Configure HTTPS listeners on ALB

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Maven dependencies
   - Verify Docker daemon is running
   - Check disk space

2. **Deployment Issues**
   - Verify EC2 security groups
   - Check Docker Compose logs: `docker-compose logs`
   - Verify environment variables

3. **Service Communication**
   - Check Consul dashboard: `http://your-ec2-ip:8500`
   - Verify network connectivity between containers

### Useful Commands

```bash
# Check Jenkins build logs
# Go to Jenkins → Your Job → Build Number → Console Output

# Check EC2 deployment
ssh -i your-key.pem ubuntu@your-ec2-ip
cd /home/ubuntu/revticket
docker-compose logs -f

# Restart services
docker-compose restart

# Clean deployment
docker-compose down -v
docker system prune -f
docker-compose up -d
```

## Monitoring and Maintenance

### 6.1 Set up CloudWatch (Optional)
- Monitor EC2 metrics
- Set up log groups for application logs

### 6.2 Backup Strategy
- Regular database backups
- Docker volume backups
- Configuration backups

### 6.3 Auto-scaling (Advanced)
- Use ECS or EKS for container orchestration
- Set up auto-scaling groups
- Configure load balancing

## Security Best Practices

1. **Use IAM roles** instead of access keys
2. **Enable VPC** for network isolation
3. **Use secrets management** for sensitive data
4. **Regular security updates** for EC2 instances
5. **Enable logging** and monitoring
6. **Use HTTPS** for all external communication

## Cost Optimization

1. **Use spot instances** for development
2. **Schedule start/stop** for non-production environments
3. **Monitor resource usage** and right-size instances
4. **Use reserved instances** for production workloads