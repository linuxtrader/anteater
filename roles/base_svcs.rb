name "base_svcs"
description "core services for every machine"
run_list [
    "recipe[ntp]",
    "recipe[postfix::sasl_auth]",
    "recipe[postfix::aliases]",
    "recipe[chef-client]"
    ]
