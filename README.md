# Edge Computing Benchmark

Cloud computing represents the de facto standard for computing today, where a user can summon a
large fleet of servers, and deploy a variety of user-customized infrastructure services (storage, resource
management, scaling, monitoring) on them in a few clicks. In contrast to cloud computing, edge computing is an emerging computing paradigm where the majority of data is generated and processed in the
field using decentralized, heterogeneous, and mobile computing devices and servers, often with limited
resources.

-------------

This repository contains Terraform code (Infrastructure-as-Code) to deploy KubeEdge, a Kubernetes based resource manager for the edge, onto the Google Cloud Platform. This repository provides code to benchmark the resource manager by varying the amount of cloud resources (Edgecore Nodes) and see the impact on the performance of KubeEdge as an edge resource manager.

## Infrastructure setup

Image of infrastructure



## Installation guide

1.   Create an account on Google Cloud Platform and create a project called `edge-benchmark`. This is the project where all the infrastructure resources will be created
2.   Go to the [service account key page in the Cloud Console](https://console.cloud.google.com/apis/credentials/serviceaccountkey) and create a new service account with Project -> Owner role. Download the credentials file in JSON format. Keep this JSON in a safe place as we are going to need it when running Terraform.
3.   Enable the GCP APIs: Storage, Compute Engine, VPC, IAM. These APIs can be enabled in the [APIs & Services Dashboard](https://console.cloud.google.com/apis/dashboard?project=edge-benchmark). If you're enabling the APIs for the first time, wait ~20-30 minutes before applying Terraform. The GCP API activation does not take immediate effect.

4.   Install Google Cloud SDK on your local machine. Details can be found in the [installation guide](https://cloud.google.com/sdk/docs/install#deb). This contains the `gsutils` required to access the Google cloud resources. 

5.   Authorize the Google Cloud SDK by typing: `gcloud auth login`.

6.   Set the current project, in this case our project is called `edge-benchmark`, so the resulting command is `gcloud config set project edge-benchmark`.

