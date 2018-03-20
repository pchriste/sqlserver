# mssql-server-rhel
# Maintainers: Travis Wright (twright-msft on GitHub)
# GitRepo: https://github.com/twright-msft/mssql-server-rhel
#MAINTAINER mssql-team mssql-team@microsoft.com 

# Base OS layer: latest RHEL 7
FROM registry.access.redhat.com/rhel7:latest
MAINTAINER pchriste@redhat.com 

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="microsoft/sql-server" \
      vendor="Microsoft Inc" \
      version="2017" \
      release="1" \
#####RHCOMMENT Best Practice labels below
      url="https://www.microsoft.com" \
      summary="SQL Server is a..." \
      description="SQL Server will do ....." \
      run='docker run -tdi --name ${NAME} ${IMAGE}' \
      io.k8s.description="SQL Server will do ....." \
      io.k8s.display-name="SQL Server" \
      io.openshift.expose-services="" \
      io.openshift.tags="sql,server"

RUN yum update -y 
### Atomic Help File - Write in Markdown, it will be converted to man format at build time.
### https://github.com/projectatomic/container-best-practices/blob/master/creating/help.adoc

COPY help.md /tmp/

RUN yum clean all && yum-config-manager --disable \* &> /dev/null && \
### Add necessary Red Hat repos here
    yum-config-manager --enable rhel-7-server-rpms,rhel-7-server-optional-rpms &> /dev/null && \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
### Add your package needs to this installation line
    yum -y install --setopt=tsflags=nodocs golang-github-cpuguy83-go-md2man && \
### help file markdown to man conversion
    go-md2man -in /tmp/help.md -out /help.1 && yum -y remove golang-github-cpuguy83-go-md2man && \
    yum clean all


# Install latest mssql-server package
#####RHCOMMENT it is assumed by RH that the build is done on a registered RH system. In that case, this subscription manager line isn't needed.
#RUN subscription-manager register --username <your_username> --password <your_password> --auto-attach
RUN yum install -y curl
RUN curl https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo > /etc/yum.repos.d/mssql-server.repo
RUN yum install -y mssql-server

# Default SQL Server TCP/Port
EXPOSE 1433

#Import the sqlservr.sh script
ADD ./sqlservr.sh /opt/mssql/bin/
RUN chmod a+x /opt/mssql/bin/sqlservr.sh

# Run SQL Server process
CMD /bin/bash /opt/mssql/bin/sqlservr.sh
