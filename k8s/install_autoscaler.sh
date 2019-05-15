#!/usr/bin/env bash
helm install stable/cluster-autoscaler --name doers-autoscaler \
 --set "autoscalingGroups[0].name=eksctl-doers-cluster-nodegroup-mainNodeGroup-NodeGroup-3Y4BAOXJ8LJ9,autoscalingGroups[0].maxSize=10,autoscalingGroups[0].minSize=1" \
 --set sslCertHostPath=/etc/ssl/certs/ca-bundle.crt \
 --set rbac.create=true \
 --set extraArgs.scale-down-utilization-threshold=0.7 \
 --set extraArgs.scale-down-unneeded-time=1m
