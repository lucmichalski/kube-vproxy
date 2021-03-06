FROM scratch
MAINTAINER Luc Michalski <luc.michalski@blippar.com>
ADD os/centos-6-root.tar.xz /
LABEL Vendor="CentOS"
LABEL License=GPLv2

ADD config/logstash-forwarder.repo /etc/yum.repos.d/logstash-forwarder.repo
ADD config/forwarder.json /etc/logstash-forwarder.conf
ADD certs/logstash-forwarder.key /etc/pki/tls/certs/logstash-forwarder.key
ADD certs/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt

# Default command
RUN rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch; yum update -y; yum clean all && \
    yum -y install epel-release unzip git python-setuptools python-dateutil python-magic wget createrepo jq nano musl parallel rsyslog golang ca-certificates openssl tar; yum clean all

# Add s3cmd configuration file and fetching remote assets scripts
ADD config/s3cfg /.s3cfg
ADD scripts/fetch.sh /fetch

# Add the default rules for proxying LTU's services
# This proxy helps us to simplify the random application generated by LTU's Rest API
ADD config/traefik.toml /traefik.toml
ADD config/rules.toml /rules.toml
ADD config/ltuengine.full.spec /opt/ltuengine.full.spec
ADD scripts/start.sh /start
ADD scripts/check_license.sh /check_license
ADD config/datasets.txt /datasets.txt
ADD patches/vpc_security.sql /opt/vpc_security.sql
ADD patches/directories.sh /directories.sh
ADD img/blipparlogo.svg /chiwa_logo.jpg
# Setup of environement variables = Should create a global configuration file (Later)
ENV BUCKET_NAME vs-bucket-test-markers
ENV ACCESS_KEY  AKIAJX5PMOG2GMVC3RUA
ENV SECRET_KEY  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

# Fetch heavy and static content from our S3 Bucket
RUN chmod +x /directories.sh && \
    git clone https://github.com/s3tools/s3cmd.git /s3cmd && \
    cd /s3cmd && python setup.py install && \
    mkdir -p /opt/datasets && \
    mkdir -p /opt/data && \
    mkdir -p /opt/ltuengine/core && \
    mkdir -p /opt/archives && \
    chmod +x /fetch && \
    /fetch && \
    rm /opt/ltu.zip && \
    ls -l && \
    cat /opt/ltu-engine-7.6.3/licence.lic && \
    cp /opt/ltu-engine-7.6.3/licence.lic /opt/ltu-engine-7.6.3/licence-local.lic && sed -i -e "s/0214bf566d99/ltu76/g" /opt/ltu-engine-7.6.3/licence-local.lic && \
    cat /etc/hosts && \
    chmod 755 /rules.toml && \
    chmod 755 /traefik.toml && \
    chmod +x /check_license && \
    chmod +x /start && \
    cd / && \
    wget --no-check-certificate https://github.com/coreos/etcd/releases/download/v2.2.1/etcd-v2.2.1-linux-amd64.tar.gz && \
    tar -xvf ./etcd-v2.2.1-linux-amd64.tar.gz && \
    ls -l && \
    cp -Rf ./etcd-v2.2.1-linux-amd64/e* /usr/bin/ && \
    wget --no-check-certificate https://github.com/mailgun/vulcand/releases/download/v0.8.0-beta.3/vulcand-v0.8.0-beta.3-linux-amd64.tar.gz && \
    tar -xvf ./vulcand-v0.8.0-beta.3-linux-amd64.tar.gz && \
    cp -Rf ./vulcand-v0.8.0-beta.3-linux-amd64/v* /usr/bin/ && \
    ls -l && \
    wget --no-check-certificate https://github.com/emilevauge/traefik/releases/download/v1.0.alpha.217/traefik && \
    mv ./traefik /usr/bin/traefik && \
    chmod +x /usr/bin/traefik && \
    mkdir -p /opt/certs

ADD https://github.com/hiteshjasani/nim-mungehosts/releases/download/v0.1.1/mungehosts /usr/local/bin/mungehosts
RUN chmod 755 /usr/local/bin/mungehosts

ADD webhooks /webhooks
ADD files/etc/crontab /etc/crontab
ADD files/bin/start-cron.sh /usr/bin/start-cron.sh
RUN touch /var/log/cron.log

WORKDIR /
RUN wget https://github.com/EmileVauge/traefik/releases/download/v1.0.alpha.217/traefik && pwd && ls -l && \
    mv ./traefik /traefik_d && \
    chmod +x ./traefik_d

CMD ["/start"]
