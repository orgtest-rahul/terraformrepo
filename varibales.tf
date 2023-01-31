variable "number_of_subnets" {
    type = number 
    description = "This defines the number of subnets"
    default = 3
    validation {
        condition = var.number_of_subnets < 5
        error_message = "The number of subnet must be less than 5."
    
    }
}
variable "number_of_Vms" {
    type =number
    description = "This defines the number of vms"
    default =3
}

