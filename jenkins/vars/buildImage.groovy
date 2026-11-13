// BuildApp.groovy - Shared Library Global Variable
// Builds the application from source code

def call(Map config = [:]) {
    def workspace = config.workspace ?: pwd()
    def appDir = config.appDir ?: '.'
    def buildCmd = config.buildCmd ?: 'npm ci --only=production'

    echo "Building application from: ${workspace}/${appDir}"

    dir(appDir) {
        echo "Installing dependencies..."
        sh buildCmd

        echo "Running tests..."
        def testCmd = config.testCmd ?: 'npm test'
        try {
            sh testCmd
            echo "Build and tests completed successfully"
        } catch (Exception e) {
            echo "Build or tests failed: ${e.message}"
            throw e
        }
    }
}