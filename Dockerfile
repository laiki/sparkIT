FROM sequenceiq/hadoop-docker:2.7.0

# docker run --network=host -it sequenceiq/hadoop-docker:2.7.0 /etc/bootstrap.sh -bash 

ARG DEBIAN_FRONTEND=noninteractive

RUN yum install -y wget centos-release-scl                              && \
    yum --disablerepo="*" --enablerepo="centos-sclo-rh" list *python3*  && \
    yum install -y rh-python36                                          && \
    scl enable rh-python36 bash                                         
#    pip3 install --upgrade pip


#RUN hdfs namenode -format

# Docker installation
#RUN groupadd docker             && \
#    apt install -y docker.io    && \
#    usermod -aG docker hduser

# Spark installation
ENV SPARK_HOME=/usr/local/spark

RUN cd                                                                                                       && \
    wget -q https://downloads.apache.org/spark/spark-3.0.0-preview2/spark-3.0.0-preview2-bin-hadoop2.7.tgz   && \
    tar xzf spark-3.0.0-preview2-bin-hadoop2.7.tgz                                                           && \
    rm spark-3.0.0-preview2-bin-hadoop2.7.tgz                                                                && \
    mv spark-3.0.0-preview2-bin-hadoop2.7/ /usr/local                                                        && \
    cd /usr/local                                                                                            && \
    ln -s spark-3.0.0-preview2-bin-hadoop2.7 spark                                                           && \
    echo "export PATH=$PATH:${SPARK_HOME}/bin"                >> /etc/profile.d/spark.sh    

    
#RUN pip3 install pyspark


# Hdfs ports
#EXPOSE 50010 50020 50070 50075 50090
# Mapred ports
#EXPOSE 19888
#Yarn ports
#EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
#EXPOSE 49707 2122   
