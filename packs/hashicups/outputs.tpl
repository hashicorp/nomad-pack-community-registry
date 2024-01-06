Congratulations on deploying [[ meta "pack.name" . ]]! 

Navigate to the HashiCups UI on port [[ var "nginx_port" . ]] of the Nomad client running the job.

You can find the allocation ID with:
nomad job status hashicups | grep -A 3 -i allocations

Then display the address of each service with the allocation ID from above:
nomad alloc status <ALLOC_ID> | grep -A 8 -i allocation