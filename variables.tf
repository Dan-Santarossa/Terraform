variable "may-var" {
  description = "My test variable"
  type = string
  default = "Hello"
  validation {
    condition = length(var.my-var) > 4
    error_message = "the string must be more than 4 characters"
  }
}

### OR

variable "my-var"{
    description = "My Test Variable"
    type = string
    default = "Hello"
    sensitive = true
}

### to reference a variable var.my-var

# Base Types:
# -string
# -number
# -bool

# Complex Types:
# -list, set, map, object, tuple 

#List type
variable "availability_zone_names" {
  type = list(string)
  default = [ "us-east-1" ]
}

#List of objects
variable "docker_ports" {
  type = list(object({
    internal = number
    external = number
    protocol = string
}))
default = [
    {
        internal = 8300
        external = 8300
        protocol = "tcp"
    }
  ]
}