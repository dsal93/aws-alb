#ALB Outputs


output "alb_public_url" {
  description = "Public URL for ALB"
  value       = aws_lb.external_alb.dns_name
}