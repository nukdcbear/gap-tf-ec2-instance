output "instructions" {
  value = local.instructions
}

output "private_key" {
  value     = tls_private_key.bastion.private_key_pem
  sensitive = true
}

output "instance_name" {
  value = random_pet.server.id
}

output "instance_id" {
  value = module.bastion.id
}
