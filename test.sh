#!/bin/bash

TEST_TMP=.test.tmp

# check_and_remove $container_name $image_name
check_and_remove () {
    if docker inspect --type=container "$1" > /dev/null 2>&1; then
	docker stop "$1" && docker rm "$1"
    fi
    if docker inspect --type=image "$2" > /dev/null 2>&1; then
	docker rmi "$2"
    fi
}

check_wget () {
    source .env
    if not wget http://localhost:"${FSWIKI_PORT}"/wiki.cgi > /dev/null 2>&1; then
	echo "ERROR: wget failed!!"
	exit 1
    fi
}

if command -v docker-compose; then
    DOCKER_COMPOSE="docker-compose"
else
    if command -v docker-compose.exe; then
	DOCKER_COMPOSE="docker-compose.exe"
    else
	echo 
	echo "WARNING: no docker-compose command found and skip them!!"
	echo
	DOCKER_COMPOSE=""
    fi
fi

cp -pf .env .env.org
for f_platform in alpine ubuntu ;do
    sed -i "/^FSWIKI_PLATFORM=/cFSWIKI_PLATFORM=$f_platform" .env
    for f_version in 3_6_5 latest ;do
	sed -i "/^FSWIKI_VERSION=/cFSWIKI_VERSION=$f_version" .env
	if [ "$DOCKER_COMPOSE" != "" ]; then
	    echo
	    echo "=== docker-compose version ==="
	    container_name=fswiki_${f_platform}_local_dc
	    image_name=$container_name:$f_version
	    check_and_remove $container_name $image_name
	    ./get_fswiki.sh
	    $DOCKER_COMPOSE up -d
	    echo
	    echo "== Versions of $image_name =="               | tee -a $TEST_TMP
	    ./check_versions.sh $container_name                | tee -a $TEST_TMP
	    echo "===========================================" | tee -a $TEST_TMP
	    check_wget
	    $DOCKER_COMPOSE down
	fi
	echo
	echo "=== shell version ==="
	container_name=fswiki_${f_platform}_local
	image_name=$container_name:$f_version
	check_and_remove $container_name $image_name
	./docker_build.sh
	./run_fswiki_local.sh
	echo
	echo "== Versions of $image_name =="               | tee -a $TEST_TMP
	./check_versions.sh $container_name                | tee -a $TEST_TMP
	echo "===========================================" | tee -a $TEST_TMP
	check_wget
	docker stop $container_name && docker rm $container_name
    done
done
mv -f .env .env.tmp
mv .env.org .env

echo
echo "=== Image Sizes ==="
docker images | grep fswiki_
cat $TEST_TMP
rm -f $TEST_TMP
rm -f wiki.cgi*

exit 0
