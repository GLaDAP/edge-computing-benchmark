region                    = "us-central1"
vpc_name                  = "kubeedge-infrastructure"
zone                      = "us-central1-a"
project_name              = "edge-benchmark"
edge_node_count           = 3
credentials_file_location = "edge-benchmark-ce8a406e3d76.json"
subnetwork_name           = "kubeedge-subnetwork"
gcp_storage_location      = "US-CENTRAL1"

cloudcore_machine_type    = "e2-small" #"e2-standard-2" # This one is not with shared processors
edgecore_machine_type     = "e2-small"