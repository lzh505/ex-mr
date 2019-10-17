FROM ubuntu
MAINTAINER zxaiwfg wufeigui@zixingai.com

ENV BUILD_ON 2019-09-19
COPY sources.list /etc/apt/sources.list
COPY config /tmp
#RUN mv /tmp/apt.conf /etc/apt/
RUN mkdir -p ~/.pip/
RUN mv /tmp/pip.conf ~/.pip/pip.conf

RUN apt-get update -qqy

RUN apt-get -qqy install netcat-traditional vim wget net-tools  iputils-ping  openssh-server python3-pip libaio-dev apt-utils

RUN pip3 install pandas  numpy  matplotlib  sklearn  seaborn  scipy tensorflow  gensim
# --proxy http://root:1qazxcde32@192.168.0.4:7890/
#添加JDK
ADD ./jdk-8u101-linux-x64.tar.gz /usr/local/
#添加hadoop
ADD ./hadoop-2.7.3.tar.gz  /usr/local
#add hbase
ADD ./hbase-1.3.5-bin.tar.gz  /usr/local
#add zookeeper
ADD ./zookeeper-3.4.14.tar.gz  /usr/local
#添加scala
ADD ./scala-2.11.8.tgz /usr/local
#添加spark
ADD ./spark-2.3.0-bin-hadoop2.7.tgz /usr/local
#添加mysql
ADD ./mysql-5.5.45-linux2.6-x86_64.tar.gz /usr/local
RUN mv /usr/local/mysql-5.5.45-linux2.6-x86_64  /usr/local/mysql
ENV MYSQL_HOME /usr/local/mysql

RUN ln -s /usr/bin/python3 /usr/bin/python

#添加hive
ADD ./apache-hive-2.3.2-bin.tar.gz /usr/local
ENV HIVE_HOME /usr/local/apache-hive-2.3.2-bin
RUN echo "HADOOP_HOME=/usr/local/hadoop-2.7.3"  | cat >> /usr/local/apache-hive-2.3.2-bin/conf/hive-env.sh
#添加mysql-connector-java-5.1.37-bin.jar到hive的lib目录中
ADD ./mysql-connector-java-5.1.37-bin.jar /usr/local/apache-hive-2.3.2-bin/lib
RUN cp /usr/local/apache-hive-2.3.2-bin/lib/mysql-connector-java-5.1.37-bin.jar /usr/local/spark-2.3.0-bin-hadoop2.7/jars

#增加JAVA_HOME环境变量
ENV JAVA_HOME /usr/local/jdk1.8.0_101
#hadoop环境变量
ENV HADOOP_HOME /usr/local/hadoop-2.7.3 
ENV HBASE_HOME /usr/local/hbase-1.3.5 
ENV ZOOKEEPER_HOME /usr/local/zookeeper-3.4.14 
#scala环境变量
ENV SCALA_HOME /usr/local/scala-2.11.8
#spark环境变量
ENV SPARK_HOME /usr/local/spark-2.3.0-bin-hadoop2.7
#将环境变量添加到系统变量中
ENV PATH $HIVE_HOME/bin:$MYSQL_HOME/bin:$SCALA_HOME/bin:$SPARK_HOME/bin:$HADOOP_HOME/bin:$JAVA_HOME/bin:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$ZOOKEEPER_HOME/bin:$HBASE_HOME/bin:$PATH

RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys

COPY config /tmp
#将配置移动到正确的位置
RUN mv /tmp/ssh_config    ~/.ssh/config && chmod 600 ~/.ssh/config && \
    mv /tmp/profile /etc/profile && \
    cat /tmp/myssh.txt >> /etc/ssh/ssh_config && \
    mkdir -p /usr/local/data/hbase/zookeeper && \
    mkdir -p /usr/local/data/zkdata && \
    mv /tmp/zoo.cfg $ZOOKEEPER_HOME/conf/zoo.cfg && \
    mv /tmp/myid /usr/local/data/zkdata/myid && \
    mv /tmp/regionservers $HBASE_HOME/conf/regionservers && \
    mv /tmp/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml && \
    mv /tmp/hbase-env.sh $HBASE_HOME/conf/hbase-env.sh && \
    mv /tmp/masters $SPARK_HOME/conf/masters && \
    cp /tmp/slaves $SPARK_HOME/conf/ && \
    mv /tmp/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf && \
    mv /tmp/spark-env.sh $SPARK_HOME/conf/spark-env.sh && \ 
    cp /tmp/hive-site.xml $SPARK_HOME/conf/hive-site.xml && \
    mv /tmp/hive-site.xml $HIVE_HOME/conf/hive-site.xml && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/master $HADOOP_HOME/etc/hadoop/master && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mkdir -p /usr/local/hadoop2.7/dfs/data && \
    mkdir -p /usr/local/hadoop2.7/dfs/name && \
    mv /tmp/init_mysql.sh ~/init_mysql.sh && chmod 700 ~/init_mysql.sh && \
    mv /tmp/init_hive.sh ~/init_hive.sh && chmod 700 ~/init_hive.sh && \
    mv /tmp/restart-hadoop.sh ~/restart-hadoop.sh && chmod 700 ~/restart-hadoop.sh
RUN echo $JAVA_HOME
#设置工作目录
WORKDIR /root
#启动sshd服务
RUN /etc/init.d/ssh start
RUN chmod 600 ~/.ssh/config
#修改start-hadoop.sh权限为700
RUN chmod 700 start-hadoop.sh
#修改root密码
RUN echo "root:111111" | chpasswd
CMD ["/bin/bash"]
