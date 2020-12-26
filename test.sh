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
    if echo "${FSWIKI_PORT}" | grep ':'; then
		# addr:port
		ADDR_AND_PORT="${FSWIKI_PORT}"
	else
		# port
		ADDR_AND_PORT="localhost:${FSWIKI_PORT}"		
	fi
    if not wget http://"${ADDR_AND_PORT}"/wiki.cgi > /dev/null 2>&1; then
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
		if [ "$f_version" == "3_6_5" ]; then
			f_ver_rem="="
		else
			f_ver_rem=""		
		fi
		sed -i "/^FSWIKI_VERSION=/cFSWIKI_VERSION=$f_version" .env
		if [ "$DOCKER_COMPOSE" != "" ]; then
	    	echo
		    echo "=== docker-compose version ==="
		    container_pre_name=fswiki_${f_platform}_local_dc
		    container_name=${container_pre_name}_${f_version}
	    	image_name=$container_pre_name:$f_version
		    check_and_remove $container_name $image_name
		    ./get_fswiki.sh
	    	$DOCKER_COMPOSE up -d
		    echo
		    echo "=== Versions of $image_name ===$f_ver_rem"         | tee -a $TEST_TMP
	    	./check_versions.sh $container_name                      | tee -a $TEST_TMP
		    echo "-------------------------------------------------" | tee -a $TEST_TMP
		    check_wget
	    	$DOCKER_COMPOSE down
		fi
		echo
		echo "=== shell version ==="
		container_pre_name=fswiki_${f_platform}_local
		container_name=${container_pre_name}_${f_version}
		image_name=$container_pre_name:$f_version
		check_and_remove $container_name $image_name
		./docker_build.sh
		./run_fswiki_local.sh
		echo
		echo "=== Versions of $image_name ======$f_ver_rem"      | tee -a $TEST_TMP
		./check_versions.sh $container_name                      | tee -a $TEST_TMP
		echo "-------------------------------------------------" | tee -a $TEST_TMP
		check_wget
		docker stop $container_name && docker rm $container_name
    done
done
mv -f .env .env.tmp
mv .env.org .env

echo
echo
echo "================= Test Summary =================="
echo "===== Image Sizes ====="
docker images | grep fswiki_
echo
cat $TEST_TMP
rm -f $TEST_TMP
rm -f wiki.cgi*

exit 0
