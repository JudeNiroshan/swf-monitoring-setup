#!/bin/bash

# Check if a project name is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

PROJECT_NAME=$1

# Check if the project already exists
oc get project $PROJECT_NAME &> /dev/null

if [ $? -eq 0 ]; then
  echo "Project '$PROJECT_NAME' already exists."
else
  # Create the new OpenShift project
  oc new-project $PROJECT_NAME
fi



# Check if the project creation was successful
if [ $? -eq 0 ]; then
  echo "Project '$PROJECT_NAME' created successfully."

  # Add Helm repos for Prometheus and Grafana Operators
#   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#   helm repo add grafana https://grafana.github.io/helm-charts
#   helm repo update

#   # Install Prometheus Operator
#   helm install prometheus-operator prometheus-community/kube-prometheus-stack -n $PROJECT_NAME

#   # Check if Prometheus Operator installation was successful
#   if [ $? -eq 0 ]; then
#     echo "Prometheus Operator installed successfully in project '$PROJECT_NAME'."
#   else
#     echo "Failed to install Prometheus Operator in project '$PROJECT_NAME'."
#     exit 1
#   fi

  # Install Grafana Operator
#   helm install grafana-operator grafana/grafana-operator -n $PROJECT_NAME

  # Check if Grafana Operator installation was successful
#   if [ $? -eq 0 ]; then
#     echo "Grafana Operator installed successfully in project '$PROJECT_NAME'."
#   else
#     echo "Failed to install Grafana Operator in project '$PROJECT_NAME'."
#     exit 1
#   fi
  oc adm policy add-scc-to-user anyuid -z default
  # Install the Helm chart
  helm install greeting-swf-helm . -n $PROJECT_NAME

  # Check if the Helm installation was successful
  if [ $? -eq 0 ]; then
    echo "Helm chart installed successfully in project '$PROJECT_NAME'."
  else
    echo "Failed to install Helm chart in project '$PROJECT_NAME'."
    exit 1
  fi
else
  echo "Failed to create project '$PROJECT_NAME'."
  exit 1
fi
