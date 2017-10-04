#!/bin/bash

source setenv.sh

# FIXME: we should configure the firewall for the new allocated ports.
# FIXME: data are volatile. We should specify a system volume and make sure it uses a IaaS volume.

# Build the list of IP addresses from other nodes.
# Seeds are only used at startup.
# They have no « special purpose in cluster operations beyond the bootstrapping of nodes ».
SEEDS=""
addedIps=0
for c in `seq 0 ${cassandraNode_size}`;
do
	# Avoid duplicate addresses
	IP=cassandraNode_${c}_ip
	if [[ $SEEDS == *"${!IP}"* ]]; then
		continue
	fi

	# Format the list with a comma
	if [ "$SEEDS" != "" ]; then
		SEEDS="$SEEDS, "
	fi

	# Append the value
	SEEDS="$SEEDS${!IP}"
	
	# It is not recommended to have too many seed nodes.
	# Said differently, not all the nodes should be seeds
	# (due to performance and synchronization issues then).
	# http://docs.datastax.com/en/archived/cassandra/2.2/cassandra/architecture/archGossipAbout.html
	#
	# So, we limit the number of seeds for a given node to 3.
	addedIps=$((addedIps+1))
	if [[ "$addedIps" == "3" ]]; then
		break
	fi
done

# Launch the Docker container.
# Container ports are hard-coded in Cassandra's configuration.
# Host ports are those defined in the graph.
# FIXME: Cassandra requires the same port to be used by all the nodes, so we stick with the default ones.
#
# Restart the container if it stopped and launch a new one otherwise.
docker start ${ROBOCONF_CLEAN_REVERSED_INSTANCE_PATH} || \
docker run --name ${ROBOCONF_CLEAN_REVERSED_INSTANCE_PATH} -d \
	-e CASSANDRA_SEEDS="$SEEDS" \
	-e CASSANDRA_CLUSTER_NAME="CassieCluster" \
	-p ${interNodePort}:7000 \
	-p ${interNodeSecuredPort}:7001 \
	-p ${clientPort}:9042 \
	cassandra:$RBCF_CASSANDRA_VERSION
