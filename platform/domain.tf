resource "aws_acm_certificate" "ecs-domain-certificate" {
  domain_name       = "*.${var.ecs_domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.ecs_cluster_name}-Certificate"
  }
}

data "aws_route53_zone" "ecs-domain" {
  name          = var.ecs_domain_name
  private_zone  = false
}

resource "aws_route53_record" "ecs-cert-validation-record" {
  for_each = {
    for ecs in aws_acm_certificate.ecs-domain-certificate.domain_validation_options : ecs.domain_name => {
      name   = ecs.resource_record_name
      record = ecs.resource_record_value
      type   = ecs.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.ecs-domain.zone_id
}

resource "aws_acm_certificate_validation" "ecs-domain-certificate-validation" {
  certificate_arn = aws_acm_certificate.ecs-domain-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.ecs-cert-validation-record : record.fqdn]
}