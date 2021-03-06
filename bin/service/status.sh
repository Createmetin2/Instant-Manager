#!/bin/bash

echo -ne "\e[33mService Status:\e[0m"
echo -e " \e[32mOnline\e[0m|\e[31mOffline\e[0m|\e[33mMalfunction\e[0m|\e[35mUnknown\e[0m"
echo -e "note: press ctrl+c to skip status check"
trap "echo -e ''; exit;" SIGINT SIGTERM

pushd "../settings" > /dev/null

game_binary=$(bash get_setting.sh general game_bin)
db_binary=$(bash get_setting.sh general db_bin)

popd > /dev/null

CheckStatus()
{
	dir=$1
	name=$2
	binary=$3
	
	if [ -d "$dir" ]; then
		#echo "Entering $dir"
		cd $dir
		
		mains=(*/)
		mains=("${mains[@]%/}")
		
		for main in ${mains[@]}
		do
			echo -ne "\e[33m$main -\e[0m"
			
			cd $main
			
			cores=(*/)
			cores=("${cores[@]%/}")
			for core in ${cores[@]}
			do
				
				cd $core
				#echo $PWD
				corePath=$PWD
				
				status=$(cd ../../../../bin/service && bash cores/check_core "$corePath" $binary)
				case $status in
					0) echo -ne " \e[31m$core\e[0m";;
					1) echo -ne " \e[32m$core\e[0m";;
					2) echo -ne " \e[33m$core\e[0m";;
					*) echo -ne " \e[35m$core\e[0m";;
				esac
				
				cd ..
				
			done
			
			echo -e ""
			
			cd ..
		done
		
	else
		echo -e "\e[33m$name directory doesn't exists, missing configuration?\e[0m"
		return
	fi
	
	cd ..
}

cd ../../configuration/

dbDir="databases/"
channelsDir="channels/"

CheckStatus $dbDir "DB" $db_binary
CheckStatus $channelsDir "Channels" $game_binary

