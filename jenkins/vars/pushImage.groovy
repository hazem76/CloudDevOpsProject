// PushImage.groovy - Shared Library Global Variable
// Pushes Docker image to ECR registry

def call(Map config = [:]) {
    def ecrRepo = config.ecrRepo ?: 'ivolve-app'
    def imageTag = config.imageTag ?: "${env.BUILD_NUMBER}"
    def awsRegion = config.awsRegion ?: 'us-east-1'
    def awsAccountId = config.awsAccountId ?: ''
    def ecrCredentials = config.ecrCredentials ?: 'ecr-credentials'

    def fullImageName = "${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/${ecrRepo}:${imageTag}"
    def localImageName = config.localImageName ?: 'ivolve-app:latest'

    echo "Pushing Docker image to ECR: ${fullImageName}"

    // Tag local image for ECR
    sh "docker tag ${localImageName} ${fullImageName}"

    // Authenticate with ECR
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: ecrCredentials,
        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
    ]]) {
        sh "aws ecr get-login-password --region ${awsRegion} | docker login --username AWS --password-stdin ${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com"
        sh "docker push ${fullImageName}"
    }

    echo "Image pushed successfully: ${fullImageName}"

    return fullImageName
}