name "base"
description "stuff for every machine"
run_list [
    "recipe[ohai]",
    "role[services]",
    "recipe[basepkgs]",
    "recipe[basefiles]",
    "recipe[chef-client]",
    ]
