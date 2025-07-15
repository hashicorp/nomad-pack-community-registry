# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

tfe_hostname      = "localhost"
tfe_database_host = "localhost"
tfe_redis_host    = "localhost"

tfe_object_storage_s3_endpoint      = "s3-fakery"
tfe_object_storage_s3_access_key_id = "s3-fake-id"

# these aren't strictly required,
# but default to non-existent namespaces
tfe_namespace       = "default"
tfe_agent_namespace = "default"
