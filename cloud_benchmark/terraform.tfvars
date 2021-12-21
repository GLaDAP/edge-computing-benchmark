region                    = "us-central1"
vpc_name                  = "kubeedge-infrastructure"
zone                      = "us-central1-a"
project_name              = "edge-benchmark"
edge_node_count           = 2
credentials_file_location = "edge-benchmark-ae293e645d4a.json"
subnetwork_name           = "kubeedge-subnetwork"
gcp_storage_location      = "US-CENTRAL1"

cloudcore_machine_type    = "e2-standard-2" 
edgecore_machine_type     = "e2-small"