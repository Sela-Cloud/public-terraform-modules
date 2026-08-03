output "repositories" {
  value = {
    for key, repository in module.artifact_registry : key => {
      id   = repository.id
      name = repository.name
    }
  }
}
