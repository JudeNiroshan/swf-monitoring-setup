#!/bin/bash

# Check if a project name is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name> [init|clean]"
  exit 1
fi

PROJECT_NAME=$1
ACTION=$2
RELEASE_NAME="greeting-swf-helm"

# Function to initialize the project
initialize_project() {
  # Check if the project already exists
  oc get project $PROJECT_NAME &> /dev/null

  if [ $? -eq 0 ]; then
    echo "Project '$PROJECT_NAME' already exists."
  else
    # Create the new OpenShift project
    oc new-project $PROJECT_NAME

    # Check if the project creation was successful
    if [ $? -eq 0 ]; then
      echo "Project '$PROJECT_NAME' created successfully."
      oc adm policy add-scc-to-user anyuid -z default -n $PROJECT_NAME
    else
      echo "Failed to create project '$PROJECT_NAME'."
      exit 1
    fi
  fi

  # Check if the Helm release already exists
  helm status $RELEASE_NAME -n $PROJECT_NAME > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "Helm release '$RELEASE_NAME' found. Upgrading..."
    helm upgrade $RELEASE_NAME . -n $PROJECT_NAME --debug
    if [ $? -eq 0 ]; then
      echo "Helm release upgraded successfully in project '$PROJECT_NAME'."
    else
      echo "Failed to upgrade Helm release in project '$PROJECT_NAME'."
      exit 1
    fi
  else
    echo "Helm release '$RELEASE_NAME' not found. Installing..."
    helm install $RELEASE_NAME . -n $PROJECT_NAME --debug
    if [ $? -eq 0 ]; then
      echo "Helm chart installed successfully in project '$PROJECT_NAME'."
    else
      echo "Failed to install Helm chart in project '$PROJECT_NAME'."
      exit 1
    fi
  fi
}

# Function to clean up the project
cleanup_project() {
  echo "Cleaning up project: $PROJECT_NAME"

  # Delete the Helm release
  helm uninstall $RELEASE_NAME -n $PROJECT_NAME
  if [ $? -eq 0 ]; then
    echo "Helm release '$RELEASE_NAME' uninstalled successfully."
  else
    echo "Failed to uninstall Helm release '$RELEASE_NAME'."
    exit 1
  fi

  # Delete the OpenShift project
  oc delete project $PROJECT_NAME
  if [ $? -eq 0 ]; then
    echo "Project '$PROJECT_NAME' deleted successfully."
  else
    echo "Failed to delete project '$PROJECT_NAME'."
    exit 1
  fi
}

# Execute the appropriate function based on the action argument
case "$ACTION" in
  clean)
    cleanup_project
    ;;
  init|*)
    initialize_project
    ;;
esac
