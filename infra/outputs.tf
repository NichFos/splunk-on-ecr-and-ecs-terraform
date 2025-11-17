output "splunk-lb-dns" {
  value = "http://${aws_lb.splunkapp_lb01.dns_name}"
}
