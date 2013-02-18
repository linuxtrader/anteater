name "be"
description "back-end dvr machines"
run_list [
    "role[base]",
    "recipe[befiles]",
    ]
