name "fe"
description "front-end dvr machines"
run_list [
    "role[base]",
    "recipe[fefiles]",
    "recipe[fepackages]",
    ]
