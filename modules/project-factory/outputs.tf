/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "folders" {
  description = "Folder ids."
  value       = local.hierarchy
}

output "projects" {
  description = "Created projects."
  value = {
    for k, v in module.projects : k => {
      number     = v.number
      project_id = v.id
      project    = v
      automation_buckets = {
        for kk, vv in module.automation-buckets :
        trimprefix(kk, "${k}/") => vv.name
        if startswith(kk, "${k}/")
      }
      automation_service_accounts = {
        for kk, vv in module.automation-service-accounts :
        trimprefix(kk, "${k}/") => vv.email
        if startswith(kk, "${k}/")
      }
    }
  }
}

output "service_accounts" {
  description = "Service account emails."
  value = {
    for k, v in module.service-accounts : k => v.email
  }
}
