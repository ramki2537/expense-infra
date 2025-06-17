resource "aws_ssm_parameter" "web_alb_listenar_arn" {
  name = "/${var.project_name}/${var.environment}/web_alb_listenar_arn"
  type = "String"
  value = aws_lb_listener.https.arn
}