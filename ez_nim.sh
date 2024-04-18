#!/bin/ksh

#Environment variables
NIMMASTNAME=nim
NIMMASTIP=192.168.138.203
NIMLOLPP=/export/nim/lpp_source
NIMLOSPOT=/export/nim/spot
NIMLOMKSYSB=/export/nim/mksysb
NIMLOG=/export/nim/ez_nim.log
DEFRFS=5

#---------------------
clear
_CREATE_DARRAY()
{
#SIZE_ARRAY=0
#POINTER_ARRAY=1
#echo "DEBUG: CMD is $CMD"
#echo "DEBUG: Size of array ${#LSTANDALONE[@]}"
#SIZE_ARRAY=`echo "DEBUG: Size of array ${#LSTANDALONE[@]} and POINTER_ARRAY = $POINTER_ARRAY"`

PS3="Entry list items number for item details or press "Q" to move upper menu:"
select dlist_menu in `echo ${DLIST[*]}`
do
	if [[ -n $dlist_menu ]]; then
	#echo "DEBUG: dlist_menu is $dlist_menu"
	#echo "DEBUG: CMD is $CMD $dlist_menu"
	$CMD $dlist_menu
	echo "\n"
	#REPLY=
	#echo "Entry list items number for item details or press "Q" to move upper menu:"
	REPLY=
	
	else
		if [[ $REPLY == "Q" || $REPLY == "q" ]]
		then
			break
		else
			print 'Invalid. Please try again. \n'
		fi
		REPLY=
    	fi
done
}

#1 LIST
_LIST_NIM_RES()
{
print "List NIM Resource"
PS3="LIST NIM resource menu, enter choice:"
select list_nim_menu in "List all NIM resource"  "List NIM client" "List mksysb" "List spot" "List NIM network" "List lpp source" "Return to Main Menu"
do
case $list_nim_menu in

"List lpp source")
echo "List lpp source:"
lsnim -t lpp_source | awk {'print $1'}
echo ""

;;

"List all NIM resource")
echo "List all NIM resource info:"
lsnim 
echo ""
;;

"List NIM client")
lsnim -t standalone
STANDALONE=`lsnim -t standalone | awk {'print $1'}`
set -A DLIST $STANDALONE
#echo "LSTANDALONE:  ${LSTANDALONE[@]} and array size is ${#LSTANDALONE[@]}" 
echo "Input Y for details OR N to previous menu: (Y/N) >>>"
read DETAIL
	if [[ $DETAIL == "Y" || $DETAIL == "y" ]] 
	then 
		echo "\n"
		echo "Show detail NIM client info: "
		CMD="lsnim -l "
		_CREATE_DARRAY $DLIST
	elif [[ $DETAIL == "N" || $DETAIL == "n" ]]
	then 
	#	echo "N"
		break
	else
		echo "Y or N"
	fi
		
;;

"List mksysb") lsnim -t mksysb
MKSYSB=`lsnim -t mksysb | awk {'print $1'}`
set -A DLIST $MKSYSB
echo "Input Y for details OR N to previous menu: (Y/N) >>>"
read DETAIL
        if [[ $DETAIL == "Y" || $DETAIL == "y" ]]
        then
                echo "\n"
                echo "Show detail mksysb info: "
                CMD="lsnim -l "
                _CREATE_DARRAY $DLIST
        elif [[ $DETAIL == "N" || $DETAIL == "n" ]]
        then
        #       echo "N"
                break
        else
                echo "Y or N"
        fi

;;

"List spot") lsnim -t spot
SPOT=`lsnim -t spot | awk {'print $1'}`
set -A DLIST $SPOT
echo "Input Y for details OR N to previous menu: (Y/N) >>>"
read DETAIL
        if [[ $DETAIL == "Y" || $DETAIL == "y" ]]
        then
                echo "\n"
                echo "Show detail mksysb info: "
                CMD="lsnim -l "
                _CREATE_DARRAY $DLIST
        elif [[ $DETAIL == "N" || $DETAIL == "n" ]]
        then
        #       echo "N"
                break
        else
                echo "Y or N"
        fi

;;


"List NIM network") lsnim -t ent
ENT=`lsnim -t ent | awk {'print $1'}`
set -A DLIST $ENT
echo "Input Y for details OR N to previous menu: (Y/N) >>>"
read DETAIL
        if [[ $DETAIL == "Y" || $DETAIL == "y" ]]
        then
                echo "\n"
                echo "Show detail mksysb info: "
                CMD="lsnim -l "
                _CREATE_DARRAY $DLIST
        elif [[ $DETAIL == "N" || $DETAIL == "n" ]]
        then
        #       echo "N"
                break
        else
                echo "Y or N"
        fi

;;


"Return to Main Menu") _MAIN_MENU;;
esac
REPLY=
done
}

#2_CREATE
_CREATE_NIM_RES()
{
print "Create NIM Resource"
PS3="CREATE NIM resource menu, enter choice:"
select create_nim_menu in "create NIM client" "create mksysb" "create spot" "create BOS" "create NIM network" "import mksysb" "Return to Main Menu"
do
case $create_nim_menu in

"create NIM client")
echo "Input hostname or press "Q" to move upper menu: >>>"
read HOST
lsnim -t standalone | awk {'print $1'} | grep -i $HOST > /dev/null 2>&1
CHKER=$?
if [[ $CHKER -ne 0 && -n $HOST ]]
then 
	echo "hostname is $HOST"
elif [[ $HOST == "Q" || $HOST == "q" ]] 
then
	break
else
	echo "The hostname is incorrect or already in the nim client list."	
	break
fi

echo "Input IP address or press "Q" to move upper menu: >>>"
read IPADDR
if [[ -n $IPADDR ]] 
then
	echo "IPADDR is $IPADDR"
else 
	echo "The IP address is incorrect."	
	break
fi
echo ""
echo "List NIM network: "
NIMNET=`lsnim -t ent | awk {'print $1'}`
set -A NIMNETLIST $NIMNET
NIMNETSIZE=${#NIMNETLIST[@]}
NIMNETSIZEPTR=0

while  [[ -n $NIMNETSIZE && $NIMNETSIZEPTR -lt $NIMNETSIZE ]]; 
do
	echo "Option $NIMNETSIZEPTR: NIM Network Name is: [ ${NIMNETLIST[$NIMNETSIZEPTR]} ]"
	NIMNETNAME=${NIMNETLIST[$NIMNETSIZEPTR]}
	lsnim -l $NIMNETNAME | egrep "net_addr | snm | routing1"
	#echo "NIMNETSIZE is $NIMNETSIZE"
	NIMNETSIZEPTR=`expr $NIMNETSIZEPTR + 1`
	#echo "NIMNETSIZE us $NIMNETSIZE"
done

LOOPNT=0
while [[ $LOOPNT -eq 0 ]] 
do
echo "Create the new NIM Network if required."
echo "\nINPUT the ABOVE NIM Network Name e.g.: $NIMNETNAME OR press "Q" to quit: >>>"
read NIMWORK

	if [[ $NIMWORK == "Q" || $NIMWORK == "q" ]]
	then 
		break
	fi
	
	if [[ -n $NIMWORK ]]
	then
		lsnim -t ent |  awk {'print $1'} | grep -x $NIMWORK > /dev/null 2>&1
		if [[ $? -eq 0 ]]
		then
			LOOPNT=1
		fi
	fi
echo "Input NIM Network name did not match NIM server network name."
done

echo "Hostname is: $HOST"
echo "IP address is: $IPADDR"
echo "NIM network: $NIMWORK"
echo "INPUT \"Y\" if correct OR \"N\" to previous menu: (Y/N) >>>"
read ANS
if [[ $ANS == "Y" || $ANS == "y" ]]
then
	hostent -h $HOST -a $IPADDR > /dev/null 2>&1
	nim -o define -t standalone -a platform=chrp -a netboot_kernel=64 -a cable_type1=bnc -a if1="$NIMWORK $HOST 0 ent" $HOST
	lsnim -l $HOST > /dev/null 2>&1
	if [[ $? -eq 0 ]]
		then 
		echo "NIM client created."
		else
		echo "NIM client define fail."
		fi
	LOOPNTSSH=0
	while [[ $LOOPNTSSH -eq 0 ]]
	do
		echo "NIM master connect to client and initalize NIM client by SSH with root password."
		echo "Initalize NIM client now (Y/N)? >>>"
		read ANS
			if [[ $ANS == "Y" || $ANS == "y" ]]
			then
				echo "NIM client will be initalized by nim master."
				echo "\nInput client network interface communicate to nim server e.g. en0) >>> "
				read CTINTER
				RELAY="hostent -h $NIMMASTNAME -a $NIMMASTIP"
				echo "Input client host root password for adding $NIMMASTNAME and IP address to client host table."
				ssh root@$HOST $RELAY
				RECMD="niminit -a name=$HOST -a pif_name=$CTINTER -a master=$NIMMASTNAME -a platform=chrp"
				echo "Input client host root password for client initialize client nim."
				ssh root@$HOST $RECMD
				lsnim -t standalone | grep -i $HOST 
				LOOPNTSSH=1
			elif [[ $ANS == "N" || $ANS == "n" ]]
			then
				echo "NIM client will not be initalized and user will initalize manually."
				LOOPNTSSH=1
			else
				echo "Input Y or N"
			fi

	done
	else	
		break
	fi
;;

"create mksysb")
echo "Create mksysb: "
MKSYSB=`lsnim -t mksysb | awk {'print $1'}`
set -A MKSYSBLIST $MKSYSB 
MKSYSBSIZE=${#MKSYSBLIST[@]}
echo "Existing defined mksysb:"
MKSYSBPTR=0
while  [[ -n $MKSYSBSIZE && $MKSYSBPTR -lt $MKSYSBSIZE ]];
do
	echo "mksysb Name is  ${MKSYSBLIST[$MKSYSBPTR]}"
	MKSYSBNAME=${MKSYSBLIST[$MKSYSBPTR]}
	#lsnim -l $MKSYSBNAME | egrep "location | oslevel_r | extracted_spot | creation_date"
	MKSYSBPTR=`expr $MKSYSBPTR + 1`
done
echo "\nDefined NIM clients:"
lsnim -t standalone | awk {'print $1'}
echo "\nInput defined hostname: OR press "Q" to quit >>>"
read HOSTNAME
if [[ $HOSTNAME == "Q" || $HOSTNAME == "q" ]]
then 
	break
fi


echo "\nInput mksysb name:  OR press "Q" to quit >>>"
read MKSBNAME
if [[ $MKSBNAME == "Q" || $MKSBNAME == "q" ]]
then
	break
fi 

echo "\nHostname: $HOSTNAME will create mksysb backup with name $MKSBNAME. Press Y to proceed OR Press N to abort."
LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
read ANS
if [[  $ANS == "Y" || $ANS == "y" ]]
then 
	CMD="nim -o define -t mksysb -a server=master -a location=$NIMLOMKSYSB/$MKSBNAME -a mk_image=yes -a source=$HOSTNAME $MKSBNAME" 
	echo $CMD
	`echo $CMD`
	LOOPNT=1
elif [[ $ANS == "N" || $ANS == "n" ]] 
then
	echo "mksysb creation aborted."	
	break
else 	
	echo "Input "Y" or "N"."
fi
done
;;

"create spot")
#WORKING
#nim -o define -t spot -a server='master' -a source='ssm_mksysb' -a 
echo "Create NIM spot by mksysb:  "
LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo "INPUT one of mksysb image name from the below list. OR Press "Q" to abort."
echo ""
lsnim -t mksysb | awk {'print $1'}
echo ""
echo "INPUT mksysb name: >>>"
read MKSYSB
lsnim -t mksysb | awk {'print $1'}  | grep -x $MKSYSB
	if [[ $? -eq 0 ]]
	then
	LOOPNT=1
	elif [[ $MKSYSB == "Q" || $MKSYSB == "q" ]]
	then 
	break
	else 
	echo "INPUT mksysb name does not match nim mksysb record."
	fi
done
echo "Start create spot."
nim -o define -t spot -a server='master' -a source=$MKSYSB -a location=$NIMLOSPOT ${MKSYSB}SPOT
if [[ $? -ne 0 ]]
then
	echo "Create $MKSYSB spot FAILED."
fi
echo "SPOT was created ${MKSYSB}SPOT successfully."
lsnim -t spot | awk {'print $1'} | grep -x ${MKSYSB}SPOT
echo ""

;;

"create BOS")
LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo "Create BOS: "
echo "Select the client to create the BOS."
echo "INPUT client server name: OR press "Q" to quit >>>"
lsnim -t standalone | awk {'print $1'}
echo ""
read NIMHOST
        if [[ $NIMHOST == "Q" || $NIMHOST == "q" ]]
        then
                break
        fi
lsnim -t standalone | awk {'print $1'} | grep -x $NIMHOST
if [[ $? -ne 0 ]]
then
	echo "Input client server name did not match NIM server record."
else
	LOOPNT=1
	#nim -o bos_inst -a source='mksysb' -a spot='spot_app1mksysb' -a mksysb=mymksysb  -a preserve_res='yes' (-j) -a no_client_boot='yes' -a accept_licenses='yes' $NIMHOST
fi	
done

LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo "Select the mksysb image to create the BOS."
echo "INPUT mksysb name: OR press "Q" to quit >>>"
lsnim -t mksysb | awk {'print $1'}
echo ""
read BOSMKSYSB
	if [[ $BOSMKSYSB == "Q" || $BOSMKSYSB == "q" ]]
	then 
		break
	fi
lsnim -t mksysb | awk {'print $1'} | grep -x $BOSMKSYSB
if [[ $? -ne 0 ]]
then 
	echo "Input mksysb name did not match NIM server record."
else
	LOOPNT=1
fi	
done


LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo "Select the spot name to create the BOS."
echo "INPUT spot name: OR press "Q" to quit >>>"
lsnim -t spot  | awk {'print $1'}
echo ""
read BOSSPOT
	if [[ $BOSSPOT == "Q" || $BOSSPOT == "q" ]]
	then 
		break
	fi
lsnim -t spot | awk {'print $1'} | grep -x $BOSSPOT
if [[ $? -ne 0 ]]
then
        echo "Input spot name did not match NIM server record."
else
        LOOPNT=1
fi
done


LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo "BOS will be create with client: $NIMHOST  mksysb: $BOSMKSYSB  spot: $BOSSPOT"
echo "Press Y to proceed and N to stop >>>"
echo ""
read ANS
if [[ $ANS == "N" || $ANS == "n" ]]
then 
	break
elif [[ $ANS == "Y" || $ANS == "y" ]]
then
	echo "BOS is creating."
	nim -o bos_inst -a source='mksysb' -a spot=$BOSSPOT -a mksysb=$BOSMKSYSB  -a preserve_res='no'  -a no_client_boot='yes' -a accept_licenses='yes' $NIMHOST
	if [[ $? -eq 0 ]]
	then
		echo "BOS was created successfully."
		LOOPNT=1
	else
		echo "BOS was NOT created."
	fi

else
	echo "Input Y or N"
fi	
done
;;

"create NIM network") 
echo "Create NIM network:  "
NIMNET=`lsnim -t ent | awk {'print $1'}`
set -A NIMNETLIST $NIMNET
NIMNETSIZE=${#NIMNETLIST[@]}
echo "Existing NIM defined network and details:"
NIMNETSIZEPTR=0

while  [[ -n $NIMNETSIZE && $NIMNETSIZEPTR -lt $NIMNETSIZE ]];
do
        echo "NIM Network Name is:  ${NIMNETLIST[$NIMNETSIZEPTR]}"
        NIMNETNAME=${NIMNETLIST[$NIMNETSIZEPTR]}
        lsnim -l $NIMNETNAME | egrep "net_addr | snm | routing1"
        #echo "NIMNETSIZE is $NIMNETSIZE"
        NIMNETSIZEPTR=`expr $NIMNETSIZEPTR + 1`
        #echo "NIMNETSIZE us $NIMNETSIZE"
done

echo "\nInput NIM Network Name:  OR press "Q" to quit >>>"
read NIMWORK
if [[ $NIMWORK == "Q" || $NIMWORK == "q" ]]
then
        break
fi

echo "\nInput NIM Network Segment net_addr (a.b.c.d):  OR press "Q" to quit >>>"
read NETSEG
if [[ $NETSEG == "Q" || $NETSEG == "q" ]]
then
        break
fi

echo "\nInput NIM Network Submask snm: OR press "Q" to quit >>>"
read SUBNET
if [[ $SUBNET == "Q" || $SUBNET == "q" ]]
then
	break
fi 

echo "\nInput Network Default Gateway: OR press "Q" to quit >>>"
read GATE
if [[ $GATE == "Q" || $GATE == "q" ]]
then
        break
fi

echo "\n Create NIM network name $NIMWORK with Network Segment $NETSEG and NetMask $SUBNET Gateway $GATE"
nim -o define -t ent -a net_addr=$NETSEG -a routing1="default ${GATE}" -a snm=$SUBNET $NIMWORK
;;

"import mksysb")
#WORKING
#nim -o define -t mksysb -a server=master -a location=/export/mksysb/pf_ssm.mksysb  pf_ssm_import2
echo "Import mksysb to NIM:  "
LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo "INPUT the full path of the mksysb at the NIM server. OR Press "Q" to abort."
read LOCMKSYSB
ls $LOCMKSYSB
	if [[ $? -eq 0 ]]
	then
	LOOPNT=1
	elif [[ $LOCMKSYSB == "Q" || $LOCMKSYSB == "q" ]]
	then 
	break
	else 
	echo "INPUT mksysb path does not exist."
	fi
done
#MKSYSB NAME
LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo ""
echo "INPUT the mksysb filename at the NIM server. OR Press "Q" to abort."
read MKSYSB
ls $LOCMKSYSB/$MKSYSB
	if [[ $? -eq 0 ]]
	then
	LOOPNT=1
	elif [[ $MKSYSB == "Q" || $MKSYSB == "q" ]]
	then 
	break
	else 
	echo "INPUT mksysb file does not exist."
	fi
done

MKSYSBNM=`echo $MKSYSB | sed 's/\./\_/'`
echo "Start import mksysb to NIM."
nim -o define -t mksysb -a server='master' -a location=$LOCMKSYSB/$MKSYSB ${MKSYSBNM}_import
if [[ $? -ne 0 ]]
then
	echo "Import $MKSYSB FAILED."
fi
echo "Import mksysb ${MKSYSBNM}_import was successfully."
lsnim -t mksysb | awk {'print $1'} | grep -x ${MKSYSBNM}_import
echo ""

;;



"Return to Main Menu") _MAIN_MENU ;;

esac
done
}

_DELETE_NIM_RES()
{
print "Delete NIM Resource"
PS3="Delete NIM resource menu, enter choice:"
select delete_nim_menu in "delete NIM client" "delete mksysb" "delete spot" "delete NIM network" "delete lpp_source" "Return to Main Menu"
do
case $delete_nim_menu in

"delete lpp_source")
echo "delete lpp_source:"
lsnim -t lpp_source | awk {'print $1'}
echo "Input lpp_source name or press "Q" to move upper menu: >>>"
read DELPP
lsnim -t lpp_source | awk {'print $1'} | grep -x $DELPP > /dev/null 2>&1
CHKER=$?
if [[ $CHKER -eq 0 && -n $DELPP ]]
then 
	LOOPNT=0
	while [[ $LOOPNT -eq 0 ]]
	do
		echo "lpp_source is $DELPP"
		echo "Press Y to confirm OR N to cancel."
		read CONFIRM
		if [[ $CONFIRM == "Y" || $CONFIRM == "y" ]]
		then
			echo "Deleting lpp source..."
			nim -o remove '-F' $DELPP
			lsnim -t  lpp_source | awk {'print $1'} | grep -i $DELPP > /dev/null 2>&1
			if [[ $? -ne 0 ]]
			then 
				echo "lpp source was deleted successfully."
				echo "NIM master lpp source: "
				lsnim -t lpp_source | awk {'print $1'}
				echo ""		
				LOOPNT=1
			else
				echo "lpp source was NOT deleted. Please check."
			fi
		elif [[ $CONFIRM == "N" || $CONFIRM == "n" ]]
		then
			break

		else 
			echo "INPUT Y or N."	
		fi
	done

	else
		echo "The lpp source name is incorrect."	
		break
fi

;;

"delete NIM client")
echo "Input hostname: "
lsnim -t standalone | awk {'print $1'}
echo ""
echo "Input the nim client hostname or press "Q" to move upper menu: >>>"
read HOST
lsnim -t standalone | awk {'print $1'} | grep -x $HOST > /dev/null 2>&1
CHKER=$?
if [[ $CHKER -eq 0 && -n $HOST ]]
then 
	LOOPNT=0
	while [[ $LOOPNT -eq 0 ]]
	do
		echo "hostname is $HOST"
		echo "Press Y to confirm OR N to cancel."
		read CONFIRM
		if [[ $CONFIRM == "Y" || $CONFIRM == "y" ]]
		then
			echo "Deleting NIM client..."
			nim -F -o reset $HOST
			nim -o reset -a force=yes $HOST
			nim -Fo deallocate -a subclass=all $HOST
			nim -o remove '-F' $HOST
			lsnim -t  standalone | awk {'print $1'} | grep -i $HOST > /dev/null 2>&1
			if [[ $? -ne 0 ]]
			then 
				echo "NIM client was deleted successfully."
				LOOPNT=1
			else
				echo "NIM client was NOT deleted. Please check."
			fi
		elif [[ $CONFIRM == "N" || $CONFIRM == "n" ]]
		then
			break

		else 
			echo "INPUT Y or N."	
		fi
	done

	else
		echo "The hostname is incorrect or already in the nim client list."	
		break
fi
;;

"delete mksysb")
LOOPNT=0
        while [[ $LOOPNT -eq 0 ]]
        do
		echo "delete mksysb image."
		lsnim -t mksysb | awk {'print $1'} 
		echo ""
		echo "Input mksysb name: >>>"
		read MKSYSB
		lsnim -t mksysb | awk {'print $1'} | grep -x $MKSYSB
		if [[ $? -eq 0 ]]
		then
			echo "Delete mksysb: $MKSYSB?"
			echo "Press Y to confirm OR N to cancel."
			read CONFIRM
			if [[ $CONFIRM  == "Y" || $CONFIRM == "y" ]]
			then
				MKSYSHOST=`lsnim -l $MKSYSB | grep source_image | awk {'print $3'}`
				nim -F -o reset $MKSYSHOST > /dev/null 2>&1
				nim -o reset -a force=yes $MKSYSHOST > /dev/null 2>&1
				nim -Fo deallocate -a subclass=all $MKSYSHOST > /dev/null 2>&1
				MKSYSPOT=`lsnim -l $MKSYSB | grep extracted_spot | awk {'print $3'}`
				nim -o remove $MKSYSPOT > /dev/null 2>&1
				nim -o remove -a rm_image=yes $MKSYSB > /dev/null 2>&1
				if [[ $? -eq 0 ]]
				then
					echo "mksysb was deleted successfully."
	                                LOOPNT=1
					echo "List mksysb resouce:"
					lsnim -t mksysb | awk {'print $1'} 
					echo ""
				else
					echo "mksysb was NOT deleted. Please check."
				fi
			elif [[ $CONFIRM == "N" || $CONFIRM == "n" ]]
			then 
				break
			else
				echo "INPUT Y or N."
			fi
		else
			echo "Input mksysb name: $MKSYSB does NOT find in NIM master."
		fi	
	done
;;

"delete spot")
LOOPNT=0
        while [[ $LOOPNT -eq 0 ]]
        do
                echo "delete spot."
                lsnim -t spot | awk {'print $1'}
                echo ""
                echo "Input spot name or press "Q" to move upper menu: >>>"
                read SPOT
                lsnim -t spot | awk {'print $1'} | grep -x $SPOT > /dev/null 2>&1
                if [[ $? -eq 0 ]]
                then
                        echo "Delete spot: $SPOT?"
                        echo "Press Y to confirm OR N to cancel."
                        read CONFIRM
                        if [[ $CONFIRM  == "Y" || $CONFIRM == "y" ]]
                        then
				#HERE
                                nim -F -o reset $SPOT
                                nim -o reset -a force=yes $SPOT
                                nim -Fo deallocate -a subclass=all $SPOT
                                nim -o remove $SPOT
                                if [[ $? -eq 0 ]]
                                then
                                        echo "spot was deleted successfully."
                                        LOOPNT=1
                                else
                                        echo "spot was NOT deleted. Please check."
                                fi
                        elif [[ $CONFIRM == "N" || $CONFIRM == "n" ]]
                        then
                                break
                        else
                                echo "INPUT Y or N."
                        fi
		elif [[ $SPOT == "Q" || $SPOT == "q" ]] 	
		then	
			break
                else
                        echo "Input spot name: $SPOT does NOT find in NIM master."
                fi
        done
;;

"delete NIM network")
LOOPNT=0
        while [[ $LOOPNT -eq 0 ]]
        do
                echo "delete NIM network."
		lsnim -t ent | awk {'print $1'}
		echo ""
		echo "Input NIM network name: >>>"
		read NIMNET
		lsnim -t ent | awk {'print $1'} | grep -x $NIMNET
		if [[ $? -eq 0 ]]
                then
                        echo "Delete NIM network: $NIMNET?"
			echo "Press Y to confirm OR N to cancel."
			read CONFIRM
			if [[ $CONFIRM  == "Y" || $CONFIRM == "y" ]]
			then 
				nim -o remove $NIMNET
				if [[ $? -eq 0 ]]
				then
					echo "NIM network was deleted successfully."
					LOOPNT=1
				else
					echo "NIM network  was NOT deleted. Please check."
				fi
			elif [[ $CONFIRM == "N" || $CONFIRM == "n" ]]
			then
				break
			else
				echo "INPUT Y or N."
			fi
		else	
			echo "Input NIM network name: $NIMNET does NOT find in NIM master."
		fi
	done
;;

"Return to Main Menu") _MAIN_MENU ;;

esac
done
}

_INIT_NIM_RES()
{
print "Initialize NIM Resource"
PS3="Initialize NIM resource menu, enter choice:"
select init_nim_menu in "initialize lpp from installation media" "initialize spot by lpp" "initialize BOS for new install OS" "Return to Main Menu"
do
case $init_nim_menu in

"initialize BOS for new install OS")
LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
	echo "Create BOS for new install OS."
	echo "If NIM client did not define, then define the nim client and then create the BOS for new install OS."
	echo "Select the new OS name or press "Q" to move upper menu: >>>"
	lsnim -t standalone | awk {'print $1'}
	read NIMNAME
	echo ""
	lsnim -t standalone | awk {'print $1'} | grep -x $NIMNAME > /dev/null 2>&1 
	CHKER=$?
	if [[ $NIMNAME == "Q" || $NIMNAME == "q" ]]
	then 
		break
	elif [[ $CHKER -eq 0 && -n $NIMNAME ]]
	then 
		echo "Hostname is $NIMNAME"
		LOOPNT=1
	else 
        	echo "The hostname is incorrect or not exist in the nim client list."
	fi
done

LOOPNT=0
while [[ $LOOPNT -eq 0 ]]	 
do
	echo "Select spot or press "Q" to move upper menu: >>>"
	lsnim -t spot | awk {'print $1'}
	read SPOTNAME
	echo ""
	lsnim -t spot | awk {'print $1'} | grep -x $SPOTNAME > /dev/null 2>&1 
	CHKER=$?
	if [[ $SPOTNAME == "Q" || $SPOTNAME == "q" ]]
        then
                break
        fi

	if [[ $CHKER -eq 0 && -n $SPOTNAME ]]
	then
		echo "SPOT name is $SPOTNAME"
		LOOPNT=1
	else
		echo "Input spot name did not match NIM server record."
	fi
done

LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
	echo "Select lpp_source or press "Q" to move upper menu: >>>"
	lsnim -t lpp_source | awk {'print $1'}
        read LPPNAME
	echo ""
	lsnim -t lpp_source | awk {'print $1'} | grep -x $LPPNAME > /dev/null 2>&1
	CHKER=$?
	if [[ $LPPNAME == "Q" || $LPPNAME == "q" ]]
	then
		break
	fi
	
	if [[ $CHKER -eq 0 && -n $LPPNAME ]]
	then
		echo "LPP name is $LPPNAME"
		LOOPNT=1
	else
		echo "Input lpp_source did not match NIM server record."
	fi
done

nim -o bos_inst -a source='spot' -a spot=$SPOTNAME -a  lpp_source=$LPPNAME -a accept_licenses='yes' -a preserve_res='yes' -a force_push='no' $NIMNAME


;;

"initialize lpp from installation media") 
LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo "Create lpp resource."
echo "Input the installation media directory (example: /mnt): >>>"
read SOLPP
if [[ $SOLPP == "Q" || $SOLPP == "q" ]]
then
        break
elif    [[ -d $SOLPP ]]
then
        echo "installation media is at ${SOLPP}. "
        LOOPNT=1

else
        echo "No such directory. Please check the input media directory ${SOLPP}."
fi
done
echo "Input the lpp name: >>>"
read NMLPP
if [[ $NMLPP == "Q" || $NMLPP == "q" ]]
then
        break
else
        echo "LPP name is : $NMLPP"
fi

LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
echo "Installation media directory is at : $SOLPP "
echo "LPP nmae is : $NMLPP "
echo "Input correct (Y/N) >>>"
read CON
if [[ $CON == "N" || $CON == "n" ]]
then
        break
elif [[ $CON == "Y" || $CON == "y" ]]
then
        LOOPNT=1
        echo "lpp resource is creating..."
        nim -o define -t lpp_source -a server=master -a location=$NIMLOLPP/$NMLPP -a source=$SOLPP $NMLPP
        lsnim -t lpp_source | awk {'print $1'} | grep -x $NMLPP
        if [[ $? -ne 0 ]]
        then
                echo "Create $NMLPP lpp FAILED."
        fi
        echo "LPP was created ${NMLPP} successfully."
        lsnim -l $NMLPP
        echo ""

else
        echo "Input Y or N"
fi

done

		
;;

"initialize spot by lpp")
LOOPNT=0
while [[ $LOOPNT -eq 0 ]]
do
        echo "Create spot by lpp."
        lsnim -t lpp_source | awk {'print $1'}
        echo ""
        echo "Input the lpp name: >>>"
        read NMLPP
        if [[ $NMLPP == "Q" || $NMLPP == "q" ]]
        then
                break
        else
                lsnim -t lpp_source|awk {'print $1'} | grep -x $NMLPP > /dev/null
                if [[ $? -eq 0 ]]
                then
                        echo ""
                        echo "Input the spot name: (e.g. aix7131spot) >>>"
                        read NMSPOT
                        if [[ $NMSPOT  == "Q" || $NMSPOT  == "q" ]]
                        then
                                break
                        else
                                echo "Creating spot: $NMSPOT by lpp_source: $NMLPP ."
                                nim -o define -t spot -a source=$NMLPP -a server='master' -a location=$NIMLOSPOT/$NMSPOT $NMSPOT
                                if [[ $? -eq 0 ]]
                                then
                                        echo "Created spot: $NMSPOT successfully."
                                        LOOPNT=1
                                else
                                        echo "Create spot: $NMSPOT failed."
                                fi
                        fi

                fi
        fi
done
;;

"Return to Main Menu") _MAIN_MENU ;;

esac
done
}




_MAIN_MENU()
{
echo "NIM storage space:"
df -g | egrep -i "Free|export"
if [[ $? -eq 0 ]]
then
EXFS=`df -g | egrep -i "export" | awk {'print $3'}`
EXMNT=`df -g | egrep -i "export" | awk {'print $7'}`
set -A ARREXFS $EXFS
set -A ARREXMNT $EXMNT
ARREXFSIZE=`echo ${#ARREXFS[@]}`
EXCNTER=0
while [[ EXCNTER -lt $ARREXFSIZE ]]
do
	FREEFS=`printf "%.0f\n" ${ARREXFS[$EXCNTER]}`
	if [[ ${FREEFS} -lt $DEFRFS ]]
	then
		echo "WARNING: ${ARREXMNT[$EXCNTER]} is LESS than ${DEFRFS}GB."
		echo "Suggest extending the filesystem. Press any button to continue."
		read DUMMY
	fi
	EXCNTER=`expr $EXCNTER + 1`
done

else 
echo "No export filesystem was found."
fi


echo ""
print "EZ NIM Menu"
PS3="NIM operation menu, enter choice:"
select clean_menu in "List NIM resources" "Create NIM resources" "Delete NIM resources" "Initialize NIM resources" "Exit"
do
case $clean_menu in
"List NIM resources")
_LIST_NIM_RES;;

"Create NIM resources")
_CREATE_NIM_RES;;

"Delete NIM resources")
_DELETE_NIM_RES;;

"Initialize NIM resources")
_INIT_NIM_RES;;

"Exit") exit ;;
esac
echo "\n"
REPLY=
done
}

_MAIN_MENU
