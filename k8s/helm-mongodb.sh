helm install --name doers-mongodb \
  --set mongodbRootPassword=A344lret98,mongodbUsername=doersdb,mongodbPassword=A445f6642k86,mongodbDatabase=doers-db \
    stable/mongodb
