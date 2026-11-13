// ScanImage.groovy - Shared Library Global Variable
// Runs Trivy vulnerability scan on Docker images

def call(Map config = [:]) {
    def dockerImage = config.dockerImage ?: 'ivolve-app:latest'
    def trivySeverity = config.severity ?: 'HIGH,CRITICAL'
    def exitCode = config.exitCode ?: 0
    def trivyFormat = config.format ?: 'table'
    def outputFile = config.outputFile ?: 'trivy-scan-results.txt'

    echo "Running Trivy vulnerability scan on: ${dockerImage}"
    echo "Severity filter: ${trivySeverity}"

    sh """
    docker run --rm -v //var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy:latest image \
        --exit-code ${exitCode} \
        --severity ${trivySeverity} \
        --format ${trivyFormat} \
        --output ${outputFile} \
        ${dockerImage} || true
    """

    echo "Trivy scan completed. Results saved to: ${outputFile}"

    // Archive scan results for audit
    archiveArtifacts artifacts: outputFile, allowEmptyArchive: true

    return dockerImage
}