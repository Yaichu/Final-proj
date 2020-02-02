resource "aws_elb" "project-elb" {  
  name            = "project-elb"  
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
    Name    = "project-consul-elb"    
  }   
}

resource "aws_lb_cookie_stickiness_policy" "project-elb-stickiness" {
  name                     = "project-elb-stickiness"
  load_balancer            = "${aws_elb.project-elb.id}"
  lb_port                  = 8500
  cookie_expiration_period = 60
}
  