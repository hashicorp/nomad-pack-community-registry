[[- define "constraints" -]]
constraint {
      attribute = "${attr.kernel.name}"
      value     = "linux"
    }

[[ range $idx, $constraint := .my.constraints ]]
    constraint {
      attribute = [[ $constraint.attribute | quote ]]
  [[- if $constraint.value ]]
      value     = [[ $constraint.value | quote ]]
  [[- end ]]
  [[- if $constraint.operator  ]]
      operator  = [[ $constraint.operator | quote ]]
  [[- end ]]
    }
[[- end ]][[- end ]]
