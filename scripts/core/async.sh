#!/usr/bin/env bash

# This was literally copied from: https://github.com/zombieleet/async-bash

# This script implements 3 asynchronous function
# setTimeout
# setInterval
# async
# killJob function is not asynchronous

# check the README.md for information on how to use this script

declare -a JOB_IDS

declare -i JOBS=1;

#source ./functions.sh;

setTimeout() {
    
    local command="$1"
    local after="$2"

    read -d " " comm <<<"${command}"

    #declare -F $comm &>/dev/null

    local _isDef=$(type -t ${comm})

    if [[ -z "${_isDef}" ]];then
	printf "%s\n" "\"${command}\" is not of type { function, command} "
	
	return 1;
    fi
    
    
    [[ ! $after =~ ^[[:digit:]]+$ ]] && {
	printf "%s\n" "require an integer as the second argument but got \"$after\" "
	
	return 1;
    }

    {
	sleep ${after}
	$command
    } &
    
    JOB_IDS+=( "${JOBS} ${command}" )
    

    
    read -d " " -a __kunk__ <<< "${JOB_IDS[$(( ${#JOB_IDS[@]} - 1))]}"
    
    echo ${__kunk__}

    : $(( JOBS++ ))

}

setInterval() {
    
    local command="$1"
    local after="$2"
    
    read -d " " comm <<<"${command}"
    

    
    local _isDef=$(type -t ${comm})
    
    if [[ -z "${_isDef}" ]];then
	printf "%s\n" "\"${command}\" is not of type { function, command} "
	
	return 1;
    fi
    
    
    [[ ! $after =~ ^[[:digit:]]+$ ]] && {
	printf "%s\n" "require an integer as the second argument but got \"$after\" "
	
	return 1;
    }

    {
	while sleep ${after};do
	    $command
	done
    } &
    
    JOB_IDS+=( "${JOBS} ${command}" )
    
    read -d " " -a __kunk__ <<< "${JOB_IDS[$(( ${#JOB_IDS[@]} - 1))]}"

    echo ${__kunk__}

    : $(( JOBS++ ))
}

killJob() {
    
    local jobToKill="$1"
    local signal="$2"
    
    signal=${signal^^}
    
    [[ ! $jobToKill =~ ^[[:digit:]]+$ ]] && {
	
	printf "%s\n" "\"$jobToKill\" should be an integer ";
	
	return 1;
    }
    
    
    {
	[[ -z "$signal" ]]  && {
	    signal="SIGTERM"
	}
    } || {
	# for loop worked better than read line in this case
	local __al__signals=$(kill -l);
	local isSig=0;
	for sig in ${__al__signals};do
	    
	    [[ ! $sig =~ ^[[:digit:]]+\)$ ]] && {
		[[ $signal == $sig ]] && {
		    isSig=1;
		    break;
		}
	    }
	done
	
	(( isSig != 1 )) && {
	    signal="SIGTERM"
	}
	
    }
    
    

    for job in ${JOB_IDS[@]};do
	
	# increment job to 1 since array index starts from 0
	read -d " " -a __kunk__ <<< "${JOB_IDS[$job]}"
	
	(( __kunk__ == jobToKill )) && {
	    

	    read -d " " -a __kunk__ <<< "${JOB_IDS[$job]}"
	    
	    kill -${signal} %${__kunk__}
	    
	    local status=$?
	    
	    (( status != 0 )) && {
		

		printf "cannot kill %s %d\n" "${JOB_IDS[$job]}" "${__kunk__}"
		
		return 1;
	    }

	    printf "%d killed with %s\n" "${__kunk__}" "${signal}" 
	    
	    return 0;
	}
	
    done    
}

async() {
    
    local commandToExec="$1"
    local resolve="$2"
    local reject="$3"

    [[ -z "$commandToExec" ]] || [[ -z "$reject" ]] || [[ -z "$resolve" ]] && {
	printf "%s\n" "Insufficient number of arguments";
	return 1;
    }

    
    
    local __temp=( "$commandToExec" "$reject" "$resolve" )
    
    
    for _c in "${__temp[@]}";do

	
	read -d " " comm <<<"${_c}"
	
	type "${comm}" &>/dev/null
	
    	local status=$?
	
    	(( status != 0 )) && {
    	    printf "\"%s\" is neither a function nor a recognized command\n" "${_c}";
	    unset _c
	    return 1;
    	}
	
    done
    
    unset __temp ;  unset _c
    
    {

	__result=$($commandToExec)
	
	status=$?
	
	(( status == 0 )) && {
	    $resolve "${__result}"
	    
	} || {
	    $reject "${status}"
	}
	unset __result
    } &


    
    JOB_IDS+=( "${JOBS} ${command}" )
    
    read -d " " -a __kunk__ <<< "${JOB_IDS[$(( ${#JOB_IDS[@]} - 1))]}"
    
    echo ${__kunk__}
    

    : $(( JOBS++ ))
    
}


parallel() {

    #local funcArray="${@:1:$(( ${#@} - 1 ))}"

    local mainFunc="${1}"
    local funcArray="${2}"
    local finalFunc="${3}"

    local totalArgs=${#@}

    (( totalArgs < 3 )) && {
	printf "%s\n" "Insufficient number of argument"
	return 1;
    }

    read -d " " __cmd <<<"${mainFunc}"

    local _isDef=$(type -t ${__cmd})
    
    
     [[ -z $_isDef ]] && {
	printf "%s\n" "${__cmd} is not of type { function , alias , builtin or file }"
	return 1;
    }

     [[ "$(type -t $finalFunc)" != "function" ]] && {
	 printf "%s\n" "${finalFunc} is not of type { function }"
	 return 1;
     }
    
    for __arr in ${funcArray};do

	local __isfunc=$(type -t ${__arr})

	[[ $__isfunc != "function" ]] && {
	    
	    printf "%s\n" "${__arr} is not of type { function }"
	    return 1;
	    
	}
	
	declare __fArray+=( ${__arr} )
    done

    unset __arr

    {
	__result=$($mainFunc)

	status=$?
	
	(( status != 0 )) && {
	    $finalFunc "" "${__result}"
	    return $?;
	}
    
	local _t=0
	
	for __async in "${__fArray[@]}";do
	    
	    __result=$(${__async} "${__result}")
	    
	    status=$?
	    
	    (( status != 0 )) && {
		$finalFunc "" "${__result}"
		
		# _t has no use here, since we will be returning from this function
		#   it was only use for clarity
		
		_t=1
		return $?
	    }
	    
	done
	
	(( _t == 0 )) && {
	    $finalFunc "${__result}" ""
	}
    } &
    
    JOB_IDS+=( "${JOBS} ${command}" )
    
    read -d " " -a __kunk__ <<< "${JOB_IDS[$(( ${#JOB_IDS[@]} - 1))]}"
    
    echo ${__kunk__}
    
    
    : $(( JOBS++ ))
}