variable "device" {
  description = "A device name from the provider configuration."
  type        = string
  default     = null
}

variable "model" {
  description = "NX-OS configuration model."
  type        = any
}
