// UpdateManifestsAndPush.groovy - Shared Library Global Variable
// Updates Kubernetes deployment manifests with new image tags
// and commits/pushes changes to Git for GitOps (Argo CD)

def call(Map config = [:]) {
    def manifestPath = config.manifestPath ?: 'kubernetes/'
    def dockerImage = config.dockerImage ?: 'ivolve-app:latest'
    def gitRepo = config.gitRepo ?: 'https://github.com/hazem76/CloudDevOpsProject.git'
    def gitBranch = config.gitBranch ?: 'main'
    def gitUserName = config.gitUserName ?: 'jenkins'
    def gitUserEmail = config.gitUserEmail ?: 'jenkins@ivolve.local'
    def commitMessage = config.commitMessage ?: 'chore: update deployment image tags [ci skip]'

    echo "Updating Kubernetes manifests with image: ${dockerImage}"
    echo "Manifest path: ${manifestPath}"

    // Find and update image tags in YAML manifests
    sh """
    find ${manifestPath} -name '*.yaml' -o -name '*.yml' | while read file; do
        if grep -q 'image:' \"\$file\"; then
            sed -i 's|image: .*|image: ${dockerImage}|' \"\$file\"
            echo \"Updated image in: \$file\"
        fi
    done
    """

    // Commit and push changes
    sh "git config user.name '${gitUserName}'"
    sh "git config user.email '${gitUserEmail}'"
    sh "git add ${manifestPath}"
    sh "git commit -m '${commitMessage}'"
    sh "git push origin ${gitBranch}"

    echo "Manifests committed and pushed to ${gitRepo} (branch: ${gitBranch})"
    echo "Argo CD will detect the change and sync automatically"
}