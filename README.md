# 🚀 GitHub to Google Cloud Run CI/CD Pipeline

This repository demonstrates a complete CI/CD pipeline that automatically deploys your application from GitHub to Google Cloud Run using Google Cloud Build.

## 📋 Overview

This project showcases how to set up an automated deployment pipeline where:
1. You push code to your GitHub repository
2. Google Cloud Build automatically triggers a build
3. Your application is containerized and deployed to Cloud Run
4. Changes are live instantly with zero downtime

## 🗂️ Repository Structure

```
├── index.html              # Main HTML page explaining the CI/CD workflow
├── Dockerfile              # Container configuration for Cloud Run
├── cloudbuild.yaml         # Google Cloud Build pipeline configuration
├── .github/
│   └── workflows/
│       └── deploy.yml      # Alternative GitHub Actions workflow
└── README.md               # This documentation
```

## 📁 Essential Files Explained

### 1. `Dockerfile` ⚙️
**Purpose:** Defines how to containerize your application for Cloud Run.

**Key Points:**
- Uses nginx:alpine as base image for serving static files
- Configured to listen on port 8080 (Cloud Run requirement)
- Includes security headers and gzip compression
- Optimized for production deployment

### 2. `cloudbuild.yaml` 🔨
**Purpose:** Defines the CI/CD pipeline steps for Google Cloud Build.

**Pipeline Steps:**
1. **Build:** Creates Docker image from your code
2. **Push:** Uploads image to Google Container Registry
3. **Deploy:** Deploys container to Cloud Run
4. **Verify:** Performs health check on deployed service

### 3. `.github/workflows/deploy.yml` 🐙
**Purpose:** Alternative CI/CD pipeline using GitHub Actions.

**Benefits:**
- Runs directly in GitHub
- Better integration with GitHub features
- Free tier available for public repositories

## 🛠️ Setup Instructions

### Prerequisites
- Google Cloud Platform account
- GitHub repository
- GCP project with billing enabled

### Step 1: Enable Required APIs
```bash
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### Step 2: Create Cloud Build Trigger

1. **Open Cloud Build Console:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Navigate to Cloud Build > Triggers

2. **Create Trigger:**
   - Click "Create Trigger"
   - Connect your GitHub repository
   - Configure trigger settings:
     - **Name:** `github-to-cloudrun-trigger`
     - **Event:** Push to a branch
     - **Source:** Your connected GitHub repository
     - **Branch:** `^main$` (or `^master$`)
     - **Configuration:** Cloud Build configuration file
     - **Location:** `cloudbuild.yaml`

3. **Set Substitution Variables:**
   ```
   _SERVICE_NAME: your-app-name
   _REGION: us-central1
   ```

### Step 3: Configure IAM Permissions

Grant Cloud Build service account the necessary permissions:

```bash
# Get your project number
PROJECT_NUMBER=$(gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)")

# Grant Cloud Run Admin role
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/run.admin"

# Grant Service Account User role
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"
```

### Step 4: Test the Pipeline

1. **Make a change to your code**
2. **Commit and push to the main branch:**
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin main
   ```
3. **Monitor the build:**
   - Check Cloud Build history in GCP Console
   - Watch for successful deployment
   - Access your deployed application via Cloud Run URL

## 🎯 Pipeline Features

### Automatic Deployment ⚡
- **Trigger:** Any push to main/master branch
- **Speed:** Typically completes in 3-5 minutes
- **Zero Downtime:** Cloud Run handles traffic switching

### Security & Best Practices 🔒
- **Container Registry:** Secure image storage
- **IAM Controls:** Proper permission management  
- **Health Checks:** Automated deployment verification
- **Resource Limits:** CPU and memory constraints

### Cost Optimization 💰
- **Pay per Use:** Cloud Run charges only for actual requests
- **Auto Scaling:** Scales to zero when not in use
- **Efficient Builds:** Optimized Docker layers for faster builds

## 🔧 Customization Options

### Modify Service Configuration
Edit the `cloudbuild.yaml` file to change:
- **Memory allocation:** `--memory 512Mi`
- **CPU allocation:** `--cpu 1`
- **Max instances:** `--max-instances 10`
- **Timeout:** `--timeout 300`
- **Environment variables:** `--set-env-vars`

### Add Build Steps
You can extend the pipeline with additional steps:
```yaml
# Add testing step
- name: 'gcr.io/cloud-builders/npm'
  args: ['test']
  id: 'run-tests'

# Add security scanning
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['components', 'install', 'beta']
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['beta', 'container', 'images', 'scan', 'gcr.io/$PROJECT_ID/my-app']
```

### Environment-Specific Deployments
Create separate triggers for different environments:
- **Development:** Deploy from `develop` branch
- **Staging:** Deploy from `staging` branch  
- **Production:** Deploy from `main` branch

## 📊 Monitoring & Debugging

### View Build Logs
```bash
# List recent builds
gcloud builds list --limit=10

# View specific build logs
gcloud builds log BUILD_ID
```

### Monitor Cloud Run Service
```bash
# Get service details
gcloud run services describe SERVICE_NAME --region=REGION

# View service logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE_NAME"
```

### Common Issues & Solutions

**Build Fails:**
- Check Dockerfile syntax
- Verify all files are committed to repository
- Review Cloud Build service account permissions

**Deployment Fails:**
- Ensure Cloud Run API is enabled
- Check memory/CPU limits
- Verify port configuration (must be 8080)

**Service Not Accessible:**
- Confirm `--allow-unauthenticated` flag is set
- Check firewall rules
- Verify service is deployed successfully

## 🌟 Best Practices

1. **Version Tagging:** Use git tags for release management
2. **Branch Protection:** Require PR reviews before merging to main
3. **Secret Management:** Use Google Secret Manager for sensitive data
4. **Resource Monitoring:** Set up alerts for resource usage
5. **Backup Strategy:** Regular backups of critical configurations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the CI/CD pipeline
5. Submit a pull request

## 📚 Additional Resources

- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Deploying! 🚀**

> **Note:** Remember to replace placeholder values like `YOUR_PROJECT_ID`, `SERVICE_NAME`, and `REGION` with your actual project details.