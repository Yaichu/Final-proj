node ("linux") {
    def DockerImage = "proj_app"
    stage("Git") { // Get code from GitLab repository
        git branch: 'master',
            url: 'https://github.com/Yaichu/Mid-proj.git'
    }
            
    stage("build docker") {
        customImage = docker.build("yaeldoc1/proj_app")
    }
    
    stage("test") {
        sh 'docker images'
    }
    
    stage("push to Docker Hub") {
        withDockerRegistry(registry:[credentialsId: 'dockerhub.yaeldoc1']) {
            customImage.push()
        }
    }
    
    stage("deploy") { // Deploy the app
        kubernetesDeploy(kubeconfigId: 'e17f6f2f-5636-4ed1-a2e3-180aa99403e9', configs: 'CI-CD/k8sdeploy.yml', enableConfigSubstitution: true)
    }
    
    stage("expose service") { // Expose the app to the world
        kubernetesDeploy(kubeconfigId: 'e17f6f2f-5636-4ed1-a2e3-180aa99403e9', configs: 'CI-CD/k8sservice.yml', enableConfigSubstitution: true)
    }
}