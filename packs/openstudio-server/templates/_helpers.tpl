// Scheduling helper templates for task-group placement controls.
//
// ─── Namespaced macros (openstudio_server.*) ─────────────────────────────────
//
// openstudio_server.node_class_constraint
//   Emits a hard constraint targeting the ${attr.nomad.node.class} attribute.
//   Call with a string value:
//     [[ template "openstudio_server.node_class_constraint" "compute" ]]
//
// openstudio_server.compute_node_constraint
//   Convenience wrapper — constrains to var "compute_node_class".
//   Call with the root context:
//     [[ template "openstudio_server.compute_node_constraint" . ]]
//
// openstudio_server.system_node_constraint
//   Convenience wrapper — constrains to var "system_node_class".
//   Call with the root context:
//     [[ template "openstudio_server.system_node_constraint" . ]]
//
// openstudio_server.arch_constraint
//   Emits hard constraints for os.name = linux and cpu.arch = amd64.
//   Call with the root context:
//     [[ template "openstudio_server.arch_constraint" . ]]
//
// openstudio_server.node_affinity
//   Emits a soft affinity stanza. Call with a map containing keys
//   attribute, value, and (optionally) weight:
//     [[ template "openstudio_server.node_affinity" (dict "attribute" "${attr.nomad.node.class}" "value" "compute" "weight" 100) ]]
//
// ─────────────────────────────────────────────────────────────────────────────

[[- define "constraints" -]]
[[- range $constraint := . ]]
constraint {
  attribute = [[ $constraint.attribute | quote ]]
  [[- if $constraint.operator ]]
  operator = [[ $constraint.operator | quote ]]
  [[- end ]]
  value = [[ $constraint.value | quote ]]
}
[[- end -]]
[[- end -]]

[[- define "affinities" -]]
[[- range $affinity := . ]]
affinity {
  attribute = [[ $affinity.attribute | quote ]]
  [[- if $affinity.operator ]]
  operator = [[ $affinity.operator | quote ]]
  [[- end ]]
  value = [[ $affinity.value | quote ]]
  [[- if $affinity.weight ]]
  weight = [[ $affinity.weight ]]
  [[- end ]]
}
[[- end -]]
[[- end -]]

[[- define "spreads" -]]
[[- range $spread := . ]]
spread {
  attribute = [[ $spread.attribute | quote ]]
  [[- if $spread.weight ]]
  weight = [[ $spread.weight ]]
  [[- end ]]
  [[- if $spread.targets ]]
  [[- range $target := $spread.targets ]]
  target [[ $target.value | quote ]] {
    percent = [[ $target.percent ]]
  }
  [[- end ]]
  [[- end ]]
}
[[- end -]]
[[- end -]]

[[- define "openstudio_server.node_class_constraint" -]]

constraint {
  attribute = "${attr.nomad.node.class}"
  value     = "[[ . ]]"
}
[[- end -]]

[[- define "openstudio_server.compute_node_constraint" -]]
[[ template "openstudio_server.node_class_constraint" (var "compute_node_class" .) ]]
[[- end -]]

[[- define "openstudio_server.system_node_constraint" -]]
[[ template "openstudio_server.node_class_constraint" (var "system_node_class" .) ]]
[[- end -]]

[[- define "openstudio_server.arch_constraint" -]]

constraint {
  attribute = "${attr.os.name}"
  value     = "linux"
}

constraint {
  attribute = "${attr.cpu.arch}"
  value     = "amd64"
}
[[- end -]]

[[- define "openstudio_server.node_affinity" -]]

affinity {
  attribute = "[[ .attribute ]]"
  value     = "[[ .value ]]"
  weight    = [[ if .weight ]][[ .weight ]][[- else ]]50[[- end ]]
}
[[- end -]]
