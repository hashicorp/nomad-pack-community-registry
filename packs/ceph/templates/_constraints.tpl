[[ define "constraints" ]]
    constraint {
      attribute = "${attr.kernel.name}"
      value     = "linux"
    }

    constraint {
      attribute = "${attr.driver.docker.privileged.enabled}"
      value     = true
    }

[[ range $idx, $constraint := var "constraints" . ]]
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
