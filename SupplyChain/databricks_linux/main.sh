#!/bin/bash

echo "Supply_Chain";
echo ${3}
sudo apt-get -y install git;
sudo pip3 install wheel;
sudo pip3 install databricks-cli;
sudo apt-get -y install expect;
sudo apt-get -y install jq ;

git clone https://github.com/Prateekagarwal9/supplychain-new;
apt-get update -y
apt-get upgrade -y
expect ${3}/SupplyChain/databricks_linux/creds.sh ${1} ${2};
databricks workspace import  -f DBC -l SCALA ${3}/supplychain-new/Supply-Chain-Solution.dbc /Supply-Chain-Solution;
databricks fs mkdirs dbfs:/databricks/init/SupplyChain/;

scripts=(
    arima_installation.sh
    prophet_installation.sh
    holtwinter_installation.sh
    lstm_installation.sh
    xgboost_installation.sh
    or_installation.sh
)
for i in "${scripts[@]}"; do
    databricks fs cp ${3}/SupplyChain/databricks_linux/$i dbfs:/databricks/init/SupplyChain/;
done

jsons=(
    arima.json
    prophet.json
    holtwinter.json
    lstm.json
    xgboost.json
    or.json
    os.json
    timefence.json
)
for i in "${jsons[@]}"; do
    runid=$(databricks jobs create --json-file ${3}/SupplyChain/databricks_linux/$i);
    echo $runid;
    runidnew=$(echo $runid | jq -r '.job_id');
    echo $runidnew;
    databricks jobs run-now --job-id $runidnew;
done
