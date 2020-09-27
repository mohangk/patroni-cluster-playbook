#!/bin/bash

gcloud compute instances stop pg12-instance
gcloud compute disks create $2 --source-snapshot pg12-instance-202009101355 --zone=us-central1-a
gcloud compute instances detach-disk pg12-instance --disk $1
gcloud compute instances attach-disk pg12-instance --disk $2 --boot
gcloud compute instances start pg12-instance
gcloud compute disks delete $1
