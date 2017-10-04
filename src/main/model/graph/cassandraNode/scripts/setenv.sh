#!/bin/bash

# Define a default version for Cassandra
# (if not already defined through the environment).
#
# TODO in Roboconf:
# allow to configure the version through a centralized configuration.
# See https://github.com/roboconf/roboconf-platform/issues/141
if [ "$RBCF_CASSANDRA_VERSION" = "" ]; then

	# http://docs.datastax.com/en/archived/cassandra/2.2/cassandra/configuration/configCassandra_yaml.html
	RBCF_CASSANDRA_VERSION="2.2.3"
fi
