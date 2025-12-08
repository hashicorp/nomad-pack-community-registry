# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

name      = "clickhouse-data"
type      = "host"

plugin_id = "mkdir"

capability {
  access_mode     = "single-node-single-writer"
  attachment_mode = "file-system"
}
