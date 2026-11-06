variable "subscription_id" {
  type        = string
  description = "Selected subscription supplied privately; no default or backend is included."
}
variable "enable_network" {
  type        = bool
  default     = false
  description = "Public-reference activation guard; never use this default to reconcile existing live state."
}
variable "location" {
  type    = string
  default = "centralus"
}
variable "tags" {
  type    = map(string)
  default = { environment = "reference", workload = "network-foundation", owner = "platform-engineering", managed_by = "terraform", data_class = "internal", cost_center = "engineering" }
}
