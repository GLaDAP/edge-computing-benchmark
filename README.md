# Edge Computing Benchmark (Cloud and Local)

Cloud computing represents the defacto standard for computing today, where a user can summon a large fleet of servers, and deploy a variety of user-customized infrastructure services (storage, resource management, scaling, monitoring) on them in a few clicks. In contrast to cloud computing, edge computing is an emerging computing paradigm where the majority of data is generated and processed in the field using decentralized, heterogeneous, and mobile computing devices and servers, often with limited resources.

-------------

This repository contains Terraform code (Infrastructure-as-Code) to deploy an *n*-node [KubeEdge](https://kubeedge.io/en/) cluster, a Kubernetes based resource manager for the edge, onto the Google Cloud Platform and code to deploy an *n*-node KubeEdge cluster locally using Vagrant. Each virtual machine is then provisioned using Ansible playbooks.

## Repository Structure

- `cloud_benchmark/` contains all files required to deploy the KubeEdge cluster to Google Cloud using Terraform.
  - `cloud_benchmark/ansible` contains the Ansible playbooks for the cloudcore and edgecore nodes as well as the manifest to enable the metrics-server on the cloudcore.
  - `cloud_benchmark/modules` contains two modules with the definitions for the `google_compute_instance` and networking.
- `local_benchmark/` contains all files required to deploy the KubeEdge cluster on multiple virtual machines using Vagrant.
  - `local_benchmark/manifests/cloudcore/` contains the manifest used to deploy the metrics server on the cloudcore.
  - `local_benchmark/playbooks/` contains the Ansible playbooks to provision the cloudcore and edgecore virtual machines.
- `edge-benchmark-report-VU.pdf`: The report with project details, benchmark and general findings. 

## General setup

![](README.assets/local-setup.drawio.png)

In the local and cloud setup, one VM is provisioned as the Cloudcore and one or multiple VMs are provisioned as Edgecore nodes. The communication is done using a subnet (either Virtualbox net locally or Google Cloud subnetwork).

# Local Setup

For the local setup, Vagrant from Hashicorp is used. It provides a way to deploy VMs with a Hypervisor of choice on a easy way with the configuration declared in a Vagrantfile. In order to execute KubeEdge locally, we need to install Vagrant and Virtualbox.

## Prerequisites

1.   Download and install Virtualbox: https://www.virtualbox.org/wiki/Downloads
2.   Download and install Vagrant: https://www.vagrantup.com/downloads. More information about the installation can be found here: https://www.vagrantup.com/docs/installation. Be aware that running Vagrant with multiple hypervisors can cause problems, as mentioned in the documentation of Vagrant.
3.   Clone this repository and navigate to the folder `local_benchmark`.

## Vagrant (VM deployment)

We take a closer look on the Vagrant file:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "cloudcore" do |cloudcore|
    cloudcore.vm.box = "ubuntu/bionic64"
    cloudcore.vm.hostname = "cloudcore"
    cloudcore.vm.synced_folder "manifests/", "/home/vagrant/manifests"
    cloudcore.vm.network "private_network", ip: "192.168.56.2"
    cloudcore.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 2
    end
    config.vm.provision "ansible_local" do |ansible_cloudcore|
      ansible_cloudcore.playbook = "playbooks/cloud_playbook.yml"
      ansible_cloudcore.config_file = "playbooks/ansible.cfg"
    end
  end
end
Vagrant.configure("2") do |config_edge|
  config_edge.vm.box = "ubuntu/bionic64"
  config_edge.vm.synced_folder "manifests/edgecore", "/home/vagrant/manifests/edgecore"
  config_edge.vm.provider "virtualbox" do |box_config|
    box_config.memory = 1024
    box_config.cpus = 1
  end
  N = 1 # One edgenode(s)
  (1..N).each do |edge_id|
    config_edge.vm.define "edgenode-#{edge_id}" do |edgenode|
      # Defining VM properties
      edgenode.vm.hostname = "edgenode-#{edge_id}"
      edgenode.vm.network "private_network", ip: "192.168.56.#{edge_id + 100}"
      if edge_id == N
        edgenode.vm.provision "ansible" do |ansible_edgecore|
          ansible_edgecore.limit = "all"
          ansible_edgecore.playbook = "playbooks/edge_playbook.yml"
          ansible_edgecore.config_file = "playbooks/ansible.cfg"
        end
      end
    end
  end
end
```

The Vagrant file contains Ruby-code with definitions of our virtual machines. As can be seen, we create a cloudcore VM and 1 EdgeCore node. Under the `cloudcore.vm.provider` we can specify other specifications than the default specifications with Virtualbox. More options can be found in the [documentation](https://www.vagrantup.com/docs/providers/virtualbox/configuration). 

The number of edge cores can be changed by modifying the number in the for-loop. There is also a [synced folder](https://www.vagrantup.com/docs/synced-folders): the manifest folder. This folder, while residing on the host, can be accessed by the VM's. This folder is used to share the join token with the edgecores.

-   *NOTE: The IP-address assigned to the nodes should be in the allowed range speficied in the Virtualbox networks.conf file, otherwise an error is thrown.*
-   *NOTE: Do not change the Vagrantfile while having VMs deployed. Otherwise the VMs are not recognized.*
-   *NOTE: Make sure vboxnet0 network adapter is present on the system to prevent VMs not discovering each other*.

4.   Execute `vagrant up --provider virtualbox` and wait until all the VM's are created. This can take some time depending on the amount of VM's specified as each VM is created and then the Ansible playbooks are ran.

## Ansible Playbooks

In this repository, there are multiple Ansible Playbooks for installing the components required for the cloudcore and edge core. In the files `cloud_playbook.yml` and `edge_playbook.yml` the order of the playbooks are given for each type of node.

## Verification of deployment

Check in the cloudcore if the edgenodes are registered (remember: `vagrant ssh cloudcore` to login). 

First, we check if all the nodes are created and known to the cloudcore:

```shell
vagrant@cloudcore:~$ kubectl get nodes
NAME         STATUS   ROLES                  AGE   VERSION
cloudcore    Ready    control-plane,master   10m   v1.21.0
edgenode-1   Ready    agent,edge             12s   v1.19.3-kubeedge-v1.8.0
```

All the VMs can be cleaned up using:

```shell
vagrant destroy -f
```

# Google Cloud

In the folder `cloud_benchmark` folder code is given to deploy the infrastructure for the benchmark in Google Cloud. 

**NOTE:** As of now, provisioning of the cloudcore has a bug where the second Ansible playbook generating the token needs to be started manually. Read this readme carefully for the workaround.

## Prerequisites

1. In order to run the Terraform code, [Terraform by Hashicorp](https://www.terraform.io/downloads) must be installed. 

2. Google Cloud SDK. Details on installing it can be found in the [installation guide](https://cloud.google.com/sdk/docs/install#deb). This contains the `gsutils` required to access the Google cloud resources. 

## Preparation Google Cloud API

In order to setup the infrastructure on Google Cloud, a couple of things needs to be initialized first. This is done by installing the Google Cloud SDK on your local machine and change some settings on https://console.cloud.google.com. 

1.   Create an account on Google Cloud Platform and create a project called `edge-benchmark`. This is the project where all the infrastructure resources will be created
2.   Go to the [service account key page in the Cloud Console](https://console.cloud.google.com/apis/credentials/serviceaccountkey) and create a new service account with Project -> Owner role. Download the credentials file in JSON format. Keep this JSON in a safe place as we are going to need it when running Terraform.
3.   Enable the GCP APIs: Storage, Compute Engine, VPC, IAM. These APIs can be enabled in the [APIs & Services Dashboard](https://console.cloud.google.com/apis/dashboard?project=edge-benchmark). If you're enabling the APIs for the first time, wait ~20-30 minutes before applying Terraform. The GCP API activation does not take immediate effect.
4.   Authorize the Google Cloud SDK by typing: `gcloud auth login`.
6.   Set the current project, in this case our project is called `edge-benchmark`, so the resulting command is `gcloud config set project edge-benchmark`.
6.   Change the variables in the file `cloud_benchmark/terraform.tfvars` to the desired settings.

## Deploy cloudcore and edgecore compute instances

Navigate to the `cloud_benchmark` folder. Put the authentication JSON from step 2 from the preparation into that folder and change the path of the `credentials_file_location` within the `terraform.tfvars` to that JSON file. Under `cloud_benchmark` there are some Terraform files to deploy the infrastructure and some Ansible files which provision the VM. In order to deploy the infrastructure, follow these steps:

1.   In the `cloud_benchmark` folder, execute the `terraform init` command.
2.   Execute `terraform plan --var-file="terraform.tfvars"` . This will check whether the terraform files are correct (no missing variables etc). 
3.   If there are no errors, execute  `terraform apply --var-file="terraform.tfvars"` to deploy the infrastructure into the cloud. This can take several minutes.

## Check and configure individual nodes

To check if the nodes are deployed and running, we use the Google Cloud API to ssh into the machines and to the last mile setup. While in the Terraform code it should provision the compute instance automatically, not all playbooks are executed. This is a known bug. The current solution is to ssh into the compute instances and execute the steps manually.

1. Access the compute instance by running `gcloud compute ssh kubeedge-cloudcore --zone=us-central1-a`. 

2. It is possible that the provisioner is still running, check that using `htop` and then filter on `ansible`.

3. When `ansible` is not running anymore, check if the cloudcore is deployed correctly using `sudo kubectl get nodes`. If the status of the node is `NotReady`, then you will have to run the ansible playbook again to complete the setup (replace the `bucket_url` with your own config bucket):

   ```shell
   sudo ansible-playbook /opt/ansible/controller_startup.yml --extra-vars "bucket_url=gs://edge-benchmark-config-bucket"
   ```

   Then verify again if the cloudcore is `Ready`. If so, then proceed by checking the edgecores.

### Edgecore provisioning

The EdgeCores are provisioned automatically and the Ansible Playbooks will wait with joining the Cloudcore until the join-command.txt is present in the Google Storage Bucket. However, if required, the provisioning can be done automatically:

1. Access the edge core by running `gcloud compute ssh kubeedge-edgecore-0 --zone=us-central1-a`. The zero can be changed to the number of the of the edge core you want to access.
  
2. If there is nothing under `/opt/`, then you will have to copy the files from the bucket using:
     ```sudo gsutil cp -r gs://edge-benchmark-config-bucket/ansible /opt``` Run the ansible-playbooks on the edgecores with the following command  (replace the `bucket_url` with your own config bucket):
  

```shell
ansible-playbook /opt/ansible/edge_playbook.yml --extra-vars "bucket_url=gs://edge-benchmark-config-bucket"
```

Repeat these steps for each edgecore.

### Cleanup

The infrastructure can be removed by using `terraform apply --var-file="terraform.tfvars"`

# References

-   Part of the code to run the benchmark locally is derived from the repository [johnscheuer/kubeedge-setup](johnscheuer/kubeedge-setup).
-   Part of the code to run the benchmark on Google Cloud is derived from the repository [itselavia/kubeedge-cluster-gcp](itselavia/kubeedge-cluster-gcp)

