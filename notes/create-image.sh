#!/bin/bash

gcloud compute images create $1 --source-snapshot=$2
