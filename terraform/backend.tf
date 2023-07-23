// REMOTE STATE GOOGLE CLOUD STORAGE
terraform {
  backend "gcs" {
    bucket = "widebot-task"
    prefix = "devops/tasks"
   }
}
