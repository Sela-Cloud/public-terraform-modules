################################################################################
# AWS ACM Certificate Resource
################################################################################

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  validation_method         = var.validation_method
  subject_alternative_names = var.subject_alternative_names
  key_algorithm             = var.key_algorithm
  certificate_authority_arn = var.certificate_authority_arn

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Optional Route 53 DNS Validation Records
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in(var.create_route53_records && var.validation_method == "DNS" ? aws_acm_certificate.this.domain_validation_options : []) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

# Optional Certificate Validation
resource "aws_acm_certificate_validation" "this" {
  count = var.validate_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = var.create_route53_records ? [for record in aws_route53_record.validation : record.fqdn] : null
}
