#!/usr/bin/env bash

# This was literally copied from: https://github.com/zombieleet/async-bash
# check the README.md for information on how to use this script

# set +eu

declare -a JOB_IDS
declare -i JOBS=1;

killJob() {
  local jobToKill signal __al__signals isSig 
  
  jobToKill="$1"
  signal="$2"
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
    __al__signals=$(kill -l);
    isSig=0;
    for sig in ${__al__signals}; do 
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
    read -r -d " " -a __kunk__ <<< "${JOB_IDS[$job]}"
    (( __kunk__ == jobToKill )) && {
      read -r -d " " -a __kunk__ <<< "${JOB_IDS[$job]}"
        
      kill -${signal} %${__kunk__}
        
      status=$?
        
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
  local cmdToExec resolve reject _c __temp status
  set +e # Avoid crash if any function fail

  cmdToExec="$1"
  resolve="$2"
  reject="$3"

  [[ -z "$cmdToExec" ]] || [[ -z "$reject" ]] || [[ -z "$resolve" ]] && {
    printf "%s\n" "Insufficient number of arguments";
    return 1;
  }

    
    
  __temp=( "$cmdToExec" "$reject" "$resolve" )
    
    
  for _c in "${__temp[@]}"; do
    read -r -d " " comm <<<"${_c}"
    type "${comm}" &>/dev/null
	
    status=$?
	
    (( status != 0 )) && {
      printf "\"%s\" is neither a function nor a recognized cmd\n" "${_c}";
	    unset _c
	    return 1;
    }
  done
    
  unset __temp _c
    
  {
    __result=$($cmdToExec)
    status=$?
    
    if (( status == 0 ))
    then
      $resolve "${__result}"
    else
      $reject "${status}"
    fi
    unset __result
  } &
  
  JOB_IDS+=( "${JOBS} ${cmd}" )
    
  read -r -d " " -a __kunk__ <<< "${JOB_IDS[$(( ${#JOB_IDS[@]} - 1))]}"
    
  #echo ${__kunk__}
    

  : $(( JOBS++ ))
    
}