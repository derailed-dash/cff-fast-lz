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

# automation service accounts

module "pf-sa-rw" {
  source     = "../../../modules/iam-service-account"
  count      = var.fast_stage_2.project_factory.enabled ? 1 : 0
  project_id = var.automation.project_id
  name = templatestring(var.resource_names["sa-pf_rw"], {
    name = var.fast_stage_2.project_factory.short_name
  })
  display_name = "Terraform resman project factory main service account."
  prefix       = var.prefix
  iam = {
    "roles/iam.serviceAccountTokenCreator" = [
      for k, v in local.cicd_repositories :
      module.cicd-sa-rw[k].iam_email if v.stage == "project-factory"
    ]
  }
  iam_project_roles = {
    (var.automation.project_id) = ["roles/serviceusage.serviceUsageConsumer"]
  }
  iam_storage_roles = {
    (var.automation.outputs_bucket) = ["roles/storage.objectAdmin"]
  }
}

module "pf-sa-ro" {
  source     = "../../../modules/iam-service-account"
  count      = var.fast_stage_2.project_factory.enabled ? 1 : 0
  project_id = var.automation.project_id
  name = templatestring(var.resource_names["sa-pf_ro"], {
    name = var.fast_stage_2.project_factory.short_name
  })
  display_name = "Terraform resman project factory main service account (read-only)."
  prefix       = var.prefix
  iam = {
    "roles/iam.serviceAccountTokenCreator" = [
      for k, v in local.cicd_repositories :
      module.cicd-sa-ro[k].iam_email if v.stage == "project-factory"
    ]
  }
  iam_project_roles = {
    (var.automation.project_id) = ["roles/serviceusage.serviceUsageConsumer"]
  }
  iam_storage_roles = {
    (var.automation.outputs_bucket) = [var.custom_roles["storage_viewer"]]
  }
}

# automation bucket

module "pf-bucket" {
  source     = "../../../modules/gcs"
  count      = var.fast_stage_2.project_factory.enabled ? 1 : 0
  project_id = var.automation.project_id
  name = templatestring(var.resource_names["gcs-pf"], {
    name = var.fast_stage_2.project_factory.short_name
  })
  prefix     = var.prefix
  location   = var.locations.gcs
  versioning = true
  iam = {
    "roles/storage.objectAdmin"  = [module.pf-sa-rw[0].iam_email]
    "roles/storage.objectViewer" = [module.pf-sa-ro[0].iam_email]
  }
}
