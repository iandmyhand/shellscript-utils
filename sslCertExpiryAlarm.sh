#!/bin/bash

# Type domains for checking certification expiry.
domainList=(www.google.com:80 www.google.com:443)

# Type a day when alarm start before certification expiry.
beforeDDay=60


### Set passed parameters. ###
if [ -n "$1" ]; then
        domainList=($1)
fi

if [ -n "$2" ]; then
        beforeDDay=$2
fi

### A function that print certification expiry infomation and save to file. ###
printScreenAddToFile(){
        # ${1} ==> $DOMAIN
        # ${2} ==> ${expiry_date[$(($i-1))]}
        # ${3} ==> $days_until_expiry
        # ${4} ==> server, intermediate, server certificate
        # ${5} ==> Emphasizing when expiry date comes close.
        echo -e "${5} ${1} ${4} SSL Certificate Expiration Date : ${2} : ${3} days left (UTC) ${5}"
        echo -e "${1} ${4} SSL Certificate Expiration Date : ${2} : ${3} days left (UTC) ${5}" >> expiry.txt
}

### A function to clean up. ###
cleanup(){
        rm -f expiry.txt 2> /dev/null
}

### MAIN ###
ALARM=0

for DOMAIN in ${domainList[@]}
do
        # Extracting root, intermediate and server certificate expiry date(UTC). And storing to array.
        expiry_date=($(echo Q | openssl s_client -connect $DOMAIN -showcerts 2> /dev/null | awk 'BEGIN { pipe="openssl x509 -noout -enddate | cut -d= -f2-" }/^-+BEGIN CERT/,/^-+END CERT/{ print | pipe }/^-+END CERT/{ close(pipe) }' | date -u +"%Y-%m-%d" -f -))

        echo "#### $DOMAIN ####" | tee -a expiry.txt
        for i in $(seq 1 ${#expiry_date[@]})
        do

                cal_format=$(date -u -d "${expiry_date[$(($i-1))]}" "+%d %m %Y")
                seconds_until_expiry=$(echo "$(date -u -d "${expiry_date[$(($i-1))]}" +%s) - $(date -u +%s)" | bc)
                days_until_expiry=$(echo "$seconds_until_expiry/(60*60*24)" | bc)

                if [ "$days_until_expiry" -le "$beforeDDay" ]
                then
                        ALARM=1
                        STRING_STRESS="<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<---------------------WARNING------------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
                        STRESS="\n"$STRING_STRESS"\n"$STRING_STRESS"\n"$STRING_STRESS"\n"
                fi

                if [ "$i" -eq 1 ]
                then
                        printScreenAddToFile $DOMAIN ${expiry_date[$(($i-1))]} $days_until_expiry server $STRESS
                        cal -3 $cal_format 2> /dev/null
                elif [ "$i" -eq "${#expiry_date[@]}" ]
                then    
                        printScreenAddToFile $DOMAIN ${expiry_date[$(($i-1))]} $days_until_expiry root $STRESS
                        cal -3 $cal_format 2> /dev/null
                else    
                        printScreenAddToFile $DOMAIN ${expiry_date[$(($i-1))]} $days_until_expiry intermediate $STRESS
                        cal -3 $cal_format 2> /dev/null
                fi
                
                STRESS=""
        done
        echo | tee -a expiry.txt
done
 
if [ "$ALARM" -eq 1 ]
then    
        echo "FAILURE"
#        cleanup
        exit 1
else    
        echo "SUCCESS"
        cleanup
        exit 0
fi