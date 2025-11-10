output "splunk-lb-dns" {
  value = aws_lb.splunkapp_lb01.dns_name
}
