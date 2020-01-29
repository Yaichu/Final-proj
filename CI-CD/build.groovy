node ("linux") {
    
    stage('create dockerfile') {
    sh '''
    tee Dockerfile <<-'EOF'
    FROM alpine:latest
    RUN apk update && \
    apk add  python3 
    COPY ./CI-CD/requirements.txt /app/requirements.txt
    WORKDIR /app
    RUN pip3 install -r requirements.txt
    COPY . /app
    ENTRYPOINT [ "python3" ]
    WORKDIR /app
    CMD [ "./CI-CD/app.py" ]
    EOF
    '''
  }
    
    stage("build docker") {
        customImage = docker.build("proj_app")
    }
    
    stage('Run container') {
        sh "docker stop mid-proj && docker rm mid-proj"
        sh "docker run -d --restart always --name mid-proj -p 9090:80 proj_app"
    }

    stage('test') {
        sh 'docker ps -a'
    }

}