
vm1_name='alpine1'
vm2_name='alpine2'


port=12345

function livemigration {
	echo "----------- Starting Live Migration ----------"
	VBoxManage controlvm ${vm1_name} teleport --host localhost --port ${port}
}


policy()
{
	
	CPU=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')
	
	
	FREE_DATA=`free -m | grep Mem` 
	CURRENT=`echo $FREE_DATA | cut -f3 -d' '`
	TOTAL=`echo $FREE_DATA | cut -f2 -d' '`
	
	RAM=$(echo "scale = 2; $CURRENT/$TOTAL*100" | bc)
	
	echo -e ' \t '
	echo -e ' \t 'Percentage CPU: $CPU 	 ' \t '	Percentage RAM: $RAM


	
	policy_RAM=$(echo "scale=2 ; $RAM - 75 > 0" | bc)
	policy_CPU=$(echo "scale=2 ; $CPU - 80 > 0" | bc)
	
	
		
	
	
	if ((($policy_RAM > 0) || (policy_CPU > 0)));
	then
		true
	else 
		false
	fi
	
}

function monitor_policy {

	while true
	do
		
		
		if policy;
		then 
			livemigration
			break
		else 
			echo -e ' \t \t \tNO MIGRATION'
		fi
		
	done
	
	echo -e ' \t Migration Done!'
}

monitor_policy
