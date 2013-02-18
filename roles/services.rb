name "services"
description "daemons for every machine"
run_list [
    "recipe[ntp]"
    ]
