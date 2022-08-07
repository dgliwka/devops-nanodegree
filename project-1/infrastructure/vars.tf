variable "location" {
  description = "The location to use for the resources."
  default     = "westeurope"
}

variable "project_name" {
  description = "The name of the project. Used as a prefix for naming resources."
  default     = "project-1"
}

variable "packer_image_name" {
  description = "The name of the image to use for the build."
  default     = "project-1-image"
}

variable "vm_count" {
  description = "The number of VMs to create."
  default     = "2"
}

variable "vm_size" {
  description = "The size of the VMs to create."
  default     = "Standard_B1ms"
}

variable "admin_username" {
  description = "The username for the admin user. Cannot be 'admin' nor 'administrator'"
  default     = "packer"
}

variable "public_key_path" {
  description = "The path to the private key to use for SSH."
  default     = "~/.ssh/id_rsa.pub"
}
