#!/bin/sh
healthCheck() {
	export IP_PRIVATE=$(ip addr show eth0 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
	nc -z $IP_PRIVATE 5601 &> /dev/null
	exit $?
}

preStart() {
    if [ -z "$CONSUL_ENVIRONMENT" ]; then
            export CONSUL_KVKEY="kibana";
            export CONSUL_SERVICE="elasticsearch";
    else
            export CONSUL_KVKEY="$CONSUL_ENVIRONMENT/kibana"
            export CONSUL_SERVICE="$CONSUL_ENVIRONMENT.elasticsearch"
    fi
	consul-template \
        -once \
        -dedup \
        -consul ${CONSUL_ADDRESS}:8500 \
        -template "/usr/kibana/kibana.yml.ctmpl:/usr/kibana/config/kibana.yml"
}

until
    cmd=$1
    shift 1
    $cmd "$@"
    [ "$?" -ne 127 ]
do
    exit
done