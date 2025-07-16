
helm -n cattle-fleet-system uninstall  --wait fleet
helm -n cattle-fleet-system uninstall --wait fleet-crd 
