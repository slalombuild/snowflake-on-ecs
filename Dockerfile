FROM amazonlinux:2.0.20191016.0

LABEL maintainer="Dave Masino <davem@slalom.com>"

ARG PYTHON_VERSION=3.7.6
ARG AIRFLOW_VERSION=1.10.9

ENV AIRFLOW_HOME /airflow
ENV PYENV_ROOT ${AIRFLOW_HOME}/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN set -ex \
    && yum update -y \
    && yum install git gcc tar make -y \
    && yum install zlib-devel bzip2 bzip2-devel readline-devel sqlite \
        sqlite-devel openssl-devel xz xz-devel libffi-devel findutils -y \
    && yum install nmap-ncat -y \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && git clone https://github.com/pyenv/pyenv.git ${AIRFLOW_HOME}/.pyenv \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir cryptography==2.8 \
    && pip install --no-cache-dir apache-airflow[crypto,postgres]==${AIRFLOW_VERSION} \
    && pip install --no-cache-dir snowflake-connector-python==2.0.3 \
    && pip install --no-cache-dir pytest==5.2.2 \
    && yum clean all \
    && yum autoremove gcc tar make -y \
    && yum autoremove zlib-devel bzip2 bzip2-devel sqlite-devel openssl-devel \
        xz xz-devel libffi-devel findutils -y \
    && rm -rf \
        /tmp/* \
        /var/tmp/* \
        /var/cache/yum \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base \
    && chown -R airflow:airflow ${AIRFLOW_HOME}

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY --chown=airflow:airflow airflow/airflow.cfg ${AIRFLOW_HOME}/
COPY --chown=airflow:airflow airflow/dags/. ${AIRFLOW_HOME}/dags/

EXPOSE 8080

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]

