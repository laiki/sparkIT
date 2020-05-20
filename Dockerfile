FROM ubuntu:latest

# installation of needed packages 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        openjdk-11-jdk openssh-server

# hduser creation
RUN addgroup hadoop                 && \
    useradd -s /bin/bash -g hadoop -m hduser     
#    echo "hduser:hduser" | chpasswd                             

USER hduser

# ssh 
RUN ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa && \
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
    # don't know how to runn ssh localhost without user interaction

# set up environment variables    
USER root
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/               
ENV HADOOP_INSTALL=/usr/local/hadoop                            
ENV PATH=$PATH:${HADOOP_INSTALL}/bin:${HADOOP_INSTALL}/sbin     
ENV HADOOP_MAPRED_HOME=${HADOOP_INSTALL}                        
ENV HADOOP_COMMON_HOME=${HADOOP_INSTALL}                        
ENV HADOOP_HDFS_HOME=${HADOOP_INSTALL}                          
ENV HADOOP_YARN_HOME=${HADOOP_INSTALL}                          

RUN echo "export JAVA_HOME=${JAVA_HOME}"                      >> /etc/profile    && \
    echo "export HADOOP_INSTALL=${HADOOP_INSTALL}"            >> /etc/profile    && \
    echo "export PATH=$PATH:${PATH}"                          >> /etc/profile    && \
    echo "export HADOOP_MAPRED_HOME=${HADOOP_MAPRED_HOME}"    >> /etc/profile    && \
    echo "export HADOOP_COMMON_HOME=${HADOOP_COMMON_HOME}"    >> /etc/profile    && \
    echo "export HADOOP_HDFS_HOME=${HADOOP_HDFS_HOME}"        >> /etc/profile    && \
    echo "export HADOOP_YARN_HOME=${HADOOP_YARN_HOME}"        >> /etc/profile
 
# disable IP v6
RUN echo "net.ipv6.conf.all.disable_ipv6 = 1"      >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.disable_ipv6 = 1"  >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.lo.disable_ipv6 = 1"       >> /etc/sysctl.conf 
    #echo 1 | /proc/sys/net/ipv6/conf/all/disable_ipv6 <- not working

# set up hadoop
RUN wget -q https://downloads.apache.org/hadoop/common/hadoop-2.10.0/hadoop-2.10.0.tar.gz && \
    tar xzf hadoop-2.10.0.tar.gz                                                          && \
    rm hadoop-2.10.0.tar.gz                                                               && \
    mkdir -p hadoop-2.10.0/tmp hadoop-2.10.0/name hadoop-2.10.0/data                      

RUN echo '\
<?xml version="1.0" encoding="UTF-8"?>                                      \n\
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>                 \n\
<!--                                                                        \n\
  Licensed under the Apache License, Version 2.0 (the "License");           \n\
  you may not use this file except in compliance with the License.          \n\
  You may obtain a copy of the License at                                   \n\
                                                                            \n\
    http://www.apache.org/licenses/LICENSE-2.0                              \n\
                                                                            \n\
  Unless required by applicable law or agreed to in writing, software       \n\
  distributed under the License is distributed on an "AS IS" BASIS,         \n\
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  \n\
  See the License for the specific language governing permissions and       \n\
  limitations under the License. See accompanying LICENSE file.             \n\
-->                                                                         \n\
                                                                            \n\
<!-- Put site-specific property overrides in this file. -->                 \n\
                                                                            \n\
<configuration>                                                             \n\
    <property>                                                              \n\
        <name>fs.defaultFS</name>                                           \n\
        <value>hdfs://localhost:9000</value>                                \n\
    </property>                                                             \n\
    <property>                                                              \n\
        <name>hadoop.tmp.dir</name>                                         \n\
        <value>/usr/local/hadoop/tmp</value>                                \n\
    </property>                                                             \n\
</configuration>                                                            \n\
'                   > hadoop-2.10.0/etc/hadoop/core-site.xml        && \
    echo '\
<?xml version="1.0" encoding="UTF-8"?>                                       \n\
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>                  \n\
<!--                                                                         \n\
  Licensed under the Apache License, Version 2.0 (the "License");            \n\
  you may not use this file except in compliance with the License.           \n\
  You may obtain a copy of the License at                                    \n\
                                                                             \n\
    http://www.apache.org/licenses/LICENSE-2.0                               \n\
                                                                             \n\
  Unless required by applicable law or agreed to in writing, software        \n\
  distributed under the License is distributed on an "AS IS" BASIS,          \n\
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   \n\
  See the License for the specific language governing permissions and        \n\
  limitations under the License. See accompanying LICENSE file.              \n\
-->                                                                          \n\
                                                                             \n\
<!-- Put site-specific property overrides in this file. -->                  \n\
                                                                             \n\
<configuration>                                                              \n\
	<property>                                                               \n\
		<name>dfs.replication</name>                                         \n\
		<value>1</value>                                                     \n\
	</property>                                                              \n\
	<property>                                                               \n\
		<name>dfs.permissions</name>                                         \n\
		<value>false</value>                                                 \n\
	</property>                                                              \n\
	<property>                                                               \n\
		<name>dfs.namenode.name.dir</name>                                   \n\
		<value>file:/usr/local/hadoop/name</value>                           \n\
	</property>                                                              \n\
	<property>                                                               \n\
		<name>dfs.datanode.data.dir</name>                                   \n\
		<value>file:/usr/local/hadoop/data</value>                           \n\
	</property>                                                              \n\
</configuration>                                                             \n\
'                   > hadoop-2.10.0/etc/hadoop/hdfs-site.xml        && \
    echo '\
<?xml version="1.0"?>                                                        \n\
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>                  \n\
<!--                                                                         \n\
  Licensed under the Apache License, Version 2.0 (the "License");            \n\
  you may not use this file except in compliance with the License.           \n\
  You may obtain a copy of the License at                                    \n\
                                                                             \n\
    http://www.apache.org/licenses/LICENSE-2.0                               \n\
                                                                             \n\
  Unless required by applicable law or agreed to in writing, software        \n\
  distributed under the License is distributed on an "AS IS" BASIS,          \n\
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   \n\
  See the License for the specific language governing permissions and        \n\
  limitations under the License. See accompanying LICENSE file.              \n\
-->                                                                          \n\
                                                                             \n\
<!-- Put site-specific property overrides in this file. -->                  \n\
                                                                             \n\
<configuration>                                                              \n\
    <property>                                                               \n\
        <name>mapreduce.framework.name</name>                                \n\
        <value>yarn</value>                                                  \n\
    </property>                                                              \n\
</configuration>                                                             \n\
'               > hadoop-2.10.0/etc/hadoop/mapred-site.xml          && \
    echo '\
<?xml version="1.0"?>                                                           \n\
<!--                                                                            \n\
  Licensed under the Apache License, Version 2.0 (the "License");               \n\
  you may not use this file except in compliance with the License.              \n\
  You may obtain a copy of the License at                                       \n\
                                                                                \n\
    http://www.apache.org/licenses/LICENSE-2.0                                  \n\
                                                                                \n\
  Unless required by applicable law or agreed to in writing, software           \n\
  distributed under the License is distributed on an "AS IS" BASIS,             \n\
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.      \n\
  See the License for the specific language governing permissions and           \n\
  limitations under the License. See accompanying LICENSE file.                 \n\
-->                                                                             \n\
<configuration>                                                                 \n\
<!-- Site specific YARN configuration properties -->                            \n\
	<property>                                                                  \n\
		<name>yarn.nodemanager.aux-services</name>                              \n\
		<value>mapreduce_shuffle</value>                                        \n\
	</property>                                                                 \n\
	<property>                                                                  \n\
		<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>      \n\
		<value>org.apache.hadoop.mapred.ShuffleHandler</value>                  \n\
	</property>                                                                 \n\
	<property>                                                                  \n\
		<name>yarn.nodemanager.vmem-pmem-ratio</name>                           \n\
		<value>3</value>                                                        \n\
	</property>                                                                 \n\
	<property>                                                                  \n\
		<name>yarn.nodemanager.delete.debug-delay-sec</name>                    \n\
		<value>600</value>                                                      \n\
	</property>                                                                 \n\
</configuration>                                                                \n\
'               > hadoop-2.10.0/etc/hadoop/yarn.site.xml 

RUN chown -R hduser:hadoop hadoop-2.10.0 && \
    mv hadoop-2.10.0/ /usr/local         && \
    cd /usr/local                        && \
    ln -s hadoop-2.10.0 hadoop
    
USER hduser

RUN echo '\
hadoop-daemon.sh start namenode                   \n\
hadoop-daemon.sh start datanode                   \n\
hadoop-daemon.sh start secondarynamenode          \n\
yarn-daemon.sh start resourcemanager              \n\
yarn-daemon.sh start nodemanager                  \n\
mr-jobhistory-daemon.sh start historyserver       \n\
'                   > ~/startHadoop.sh            && \
    echo '\
hadoop-daemon.sh stop namenode                   \n\
hadoop-daemon.sh stop datanode                   \n\
hadoop-daemon.sh stop secondarynamenode          \n\
yarn-daemon.sh stop resourcemanager              \n\
yarn-daemon.sh stop nodemanager                  \n\
mr-jobhistory-daemon.sh stop historyserver       \n\
'                   > ~/stopHadoop.sh

RUN chmod +x ~/st*Hadoop.sh

USER root

RUN hdfs namenode -format

