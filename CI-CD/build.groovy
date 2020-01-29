node ("Linux") {
    stage("build docker") {
        customImage = docker.build("proj_app")
    }
}