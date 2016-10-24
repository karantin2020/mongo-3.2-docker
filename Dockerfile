FROM ubuntu:xenial
	
ENV MONGO_MAJOR 3.2
ENV MONGO_VERSION 3.2.10

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
  && echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list \
  && apt-get update \
  && apt-get install -y \
	        mongodb-org \
		mongodb-org=$MONGO_VERSION \
		mongodb-org-server=$MONGO_VERSION \
		mongodb-org-shell=$MONGO_VERSION \
		mongodb-org-mongos=$MONGO_VERSION \
		mongodb-org-tools=$MONGO_VERSION \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mongodb \
	&& mv /etc/mongod.conf /etc/mongod.conf.orig \
  && mkdir -p /data/db /data/configdb \
	&& chown -R mongodb:mongodb /data/db /data/configdb \
  && mkdir -p /entry

VOLUME /data/db /data/configdb

COPY docker-entrypoint.sh /entry/entrypoint.sh
COPY mongod.service /lib/systemd/system/mongod.service

ENTRYPOINT ["/entry/entrypoint.sh"]
RUN chmod +x /entry/entrypoint.sh

EXPOSE 27017
CMD ["mongod"]
