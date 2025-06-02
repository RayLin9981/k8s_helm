#!/bin/bash
#helm repo add utkuozdemir https://utkuozdemir.org/helm-charts
helm upgrade -f values.yaml nvidia-gpu-exporter -n nvidia-gpu-exporter --create-namespace --install utkuozdemir/nvidia-gpu-exporter
