data "terraform_remote_state" "sg" {
  backend = "artifactory"
  config {
    username = "dj-artifacts-ro"
    password = "AKCp5Z2hNHR7TZaW2EH6FVNvyGHtk9EBvajqFJ1UR4ZcUruh48ubUGiLVpZVTLhhjKJBjwxAx"
    url      = "https://artifactory.dowjones.io/artifactory"
    repo     = "djin-terraform-iamsg"
    subpath  = "sg/${var.subpath}"
  }
}
