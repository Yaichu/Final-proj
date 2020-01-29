node ("docker") {
    stage("build docker") {
        customImage = docker.build("proj_app")
    }
}