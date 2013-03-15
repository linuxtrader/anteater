name "base"
description "stuff for every machine"
run_list [
    "recipe[ohai]",
    "role[base_svcs]",
    "recipe[basepkgs]",
    "recipe[basefiles]",
    ]
