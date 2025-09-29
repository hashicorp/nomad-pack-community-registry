namespace = "default"
name      = "signoz-db"
type      = "host"

# mkdir is the default built-in plugin
plugin_id = "mkdir"

# allows mounting by only one allocation at a time
capability {
  access_mode     = "single-node-single-writer"
  attachment_mode = "file-system"
}
