#!/bin/bash
NS=$1

for res in $(kubectl api-resources --verbs=list --namespaced -o name); do
  echo -e "\n### Resource: $res"
  kubectl get -n "$NS" "$res" --ignore-not-found
done

