name "services"
description "core services for every machine"
run_list [
    "recipe[ntp]",
    "recipe[postfix::sasl_auth]",
    ]
