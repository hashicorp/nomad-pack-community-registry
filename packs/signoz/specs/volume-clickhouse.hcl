# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

name      = "clickhouse-data"
type      = "host"

plugin_id = "mkdir"

capability {
  access_mode     = "single-node-single-writer"
  attachment_mode = "file-system"
}
