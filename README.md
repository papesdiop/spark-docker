# spark-docker
spark cluster docker deployment sample



# Dockerfile

FROM openjdk:8-alpine

RUN apk --update add wget tar bash

RUN wget http://www.apache.org/dyn/closer.lua/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz

RUN tar -xzf spark-2.4.5-bin-hadoop2.7.tgz && \
    mv spark-2.4.5-bin-hadoop2.7 /spark && \
    rm spark-2.4.5-bin-hadoop2.7.tgz

"""""""""""""""""""""""""""""""""""""""""""

# Set company name variable for next uses

_$> export COMPANY_NAME="osn"

# Build company spark docker image
docker build -t $COMPANY_NAME/spark:latest .

# Create dedicated network for containers communication (not required at all)
docker network create spark_network

# starting spark master node command (winpty on windows 10)
winpty docker run --rm -it --name spark-master --hostname spark-master -p 7077:7077 -p 8080:8080 --network spark_network $COMPANY_NAME/spark:latest /bin/sh

_$> /spark/bin/spark-class org.apache.spark.deploy.master.Master --ip `hostname` --port 7077 --webui-port 8080

# starting spark worker node command
 docker run --rm -it --name spark-worker --hostname spark-worker --network spark_network $COMPANY_NAME/spark:latest /bin/sh

_$> /spark/bin/spark-class org.apache.spark.deploy.worker.Worker --webui-port 8080 spark://spark-master:7077


# run spark job from spark-client container
 docker run --rm -it --network spark_network $COMPANY_NAME/spark:latest 

 _$> /spark/bin/spark-submit --master spark://spark-master:7077 --class org.apache.spark.examples.SparkPi /spark/examples/jars/spark-examples_2.11-2.4.3.jar 1000

-----------------------------------------------

# Automate with docker-compose docker-compose
see ./docker-compose.yml file

# create file start-master.sh
#!/bin/sh
/spark/bin/spark-class org.apache.spark.deploy.master.Master \
    --ip $SPARK_LOCAL_IP \
    --port $SPARK_MASTER_PORT \
    --webui-port $SPARK_MASTER_WEBUI_PORT
	
# create file start-worker.sh
#!/bin/sh
/spark/bin/spark-class org.apache.spark.deploy.worker.Worker \
    --webui-port $SPARK_WORKER_WEBUI_PORT \
    $SPARK_MASTER
    
# Add on Docekrfile	
COPY start-master.sh /start-master.sh
COPY start-worker.sh /start-worker.sh

# start cluster with 3 workers at scale
docker-compose up --scale spark-worker=3


# How to K8s 
from our docker-compose.yml, we can use Kompose to kubernetize (automatize) our docker-compose file.
for more info, let's see https://kompose.io/ 
