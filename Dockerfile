FROM openjdk:8-alpine
RUN apk --update add wget tar bash
RUN echo "check_certificate = off" >> ~/.wgetrc
RUN wget https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
RUN tar -xzf spark-2.4.3-bin-hadoop2.7.tgz && \
    mv spark-2.4.3-bin-hadoop2.7 /spark && \
    rm spark-2.4.3-bin-hadoop2.7.tgz

#Install Hadoop client
RUN wget http://apache.mirrors.pair.com/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz 
RUN tar -xzf hadoop-2.7.7.tar.gz && \
    mv hadoop-2.7.7 /hadoop && \
    rm hadoop-2.7.7.tar.gz
COPY conf/* /hadoop/conf/

COPY spark-env.sh /spark/conf/spark-env.sh
COPY spark-defaults.conf /spark/conf/spark-defaults.conf
COPY hive-site.xml /spark/conf/hive-site.xml
RUN  mkdir /tmp/spark-events
ENV PATH="/spark/bin:${PATH}"

COPY start-master.sh /start-master.sh
COPY start-worker.sh /start-worker.sh

#install kerberos --no-cache
RUN apk add  krb5-pkinit krb5-dev krb5 openssl-dev
COPY krb5.conf /etc/krb5.conf

# TODO for security concerns
COPY s_diop01.keytab /s_diop01.keytab 



COPY hive_query_test.scala /hive_query_test.scala
CMD kinit -kt s_diop01.keytab s_diop01@BIGDATA.DEV && \
    spark-shell -i hive_query_test.scala
