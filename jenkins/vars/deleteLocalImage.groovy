// DeleteLocalImage.groovy - Shared Library Global Variable
// Removes locally built Docker images to manage storage

def call(Map config = [:]) {
    def dockerImage = config.dockerImage ?: 'ivolve-app:latest'
    def force = config.force ?: true

    echo "Deleting local Docker image: ${dockerImage}"

    def flag = force ? '-f' : ''
    sh "docker rmi ${flag} ${dockerImage} || true"

    echo "Local image cleaned up: ${dockerImage}"
}