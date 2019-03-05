helm upgrade --install config-service ./configApp/

sleep 30

helm upgrade --install mainapp-service ./mainApp/
