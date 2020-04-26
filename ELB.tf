#consul-elb
resource "aws_elb" "consul-elb" {  
  name            = "consul-elb"  
  subnets         = "${aws_subnet.pub-subnet.*.id}"
  security_groups = [aws_security_group.consul_sg.id]
    listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8500"
    interval            = 15
  }

  instances                   = "${aws_instance.project_consul_server.*.id}"
#   cross_zone_load_balancing   = true
#   idle_timeout                = 60
#   connection_draining         = true
#   connection_draining_timeout = 300

  tags = {    
    Name    = "consul-elb"    
  }   
}

resource "aws_lb_cookie_stickiness_policy" "project-elb-stickiness" {
  name                     = "project-elb-stickiness"
  load_balancer            = "${aws_elb.consul-elb.id}"
  lb_port                  = 8500
  cookie_expiration_period = 60
}

#jenkins-elb
resource "aws_elb" "jenkins-elb" {
  name            = "jenkins-elb"
  subnets         = "${aws_subnet.pub-subnet.*.id}"
  security_groups = [aws_security_group.jenkins_sg.id]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = "${aws_instance.project_jenkins_master.*.id}"
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "jenkins-elb"
  }
}

#prometheus-elb
resource "aws_elb" "prom-elb" {
  name            = "prom-elb"
  subnets         = "${aws_subnet.pub-subnet.*.id}"
  security_groups = [aws_security_group.prometheus_sg.id]

  listener {
    instance_port     = 9090
    instance_protocol = "tcp"
    lb_port           = 9090
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "tcp:9090"
    interval            = 30
  }

#   instances                   = ["${aws_instance.project_jenkins_master.*.id}", "${aws_instance.project_jenkins_slave.*.id}"]
  instances                   = "${aws_instance.prometheus.*.id}"
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "prometheus-elb"
  }
}