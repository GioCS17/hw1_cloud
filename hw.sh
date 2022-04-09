#!/bin/bash

vm1_name='alpine1'
vm2_name='alpine2'

storage_name='mystorage.vdi'
storage_name2='mystorage2.vdi'

path=${PWD}

iso_linux='alpine-standard-3.13.5-x86.iso'

port=12345

echo Storage path ${path}/${storage_name}
echo ISO Linux path ${path}/${iso_linux}

function create_storage {
	echo "Creating Storage"
	VBoxManage createhd --filename ${path}/${storage_name} --size 80000 --format VDI                     
	VBoxManage createhd --filename ${path}/${storage_name2} --size 80000 --format VDI                     
	echo "Storage was created sucessfully"
}

function create_vm1 {

	echo "Creating VM ${vm1_name}"
	VBoxManage createvm --name ${vm1_name} --ostype "Linux" --register --basefolder ${path} 

	echo "Setting memory and network for VM ${vm1_name}"
	VBoxManage modifyvm ${vm1_name} --ioapic on                     
	VBoxManage modifyvm ${vm1_name} --memory 1024 --vram 128       
	VBoxManage modifyvm ${vm1_name} --nic1 nat 


	echo "Conneting VM ${vm1_name} to CD ISO"
	VBoxManage storagectl ${vm1_name} --name "SATA Controller 1" --add sata --controller IntelAhci       
	VBoxManage storageattach ${vm1_name} --storagectl "SATA Controller 1" --port 0 --device 0 --type hdd --medium  ${path}/${storage_name}                
	VBoxManage storagectl ${vm1_name} --name "IDE Controller 1" --add ide --controller PIIX4       
	VBoxManage storageattach ${vm1_name} --storagectl "IDE Controller 1" --port 1 --device 0 --type dvddrive --medium ${path}/${iso_linux}      
	VBoxManage modifyvm ${vm1_name} --boot1 dvd --boot2 disk --boot3 none --boot4 none 

	echo "Setting RDP access for the VM ${vm1_name}"
	VBoxManage modifyvm ${vm1_name} --vrde on                  
	VBoxManage modifyvm ${vm1_name} --vrdemulticon on --vrdeport 10001

	echo "${vm1_name} was create successfully"


	#VBoxManage storageattach ${vm1_name} --storagectl "IDE Controller 1" --port 1 --device 0 --type dvddrive --medium "none"     

}

function create_vm2 {

	echo "Creating VM ${vm2_name}"
	VBoxManage createvm --name ${vm2_name} --ostype "Linux" --register --basefolder ${path} 

	echo "Setting memory and network for VM ${vm2_name}"
	VBoxManage modifyvm ${vm2_name} --ioapic on                     
	VBoxManage modifyvm ${vm2_name} --memory 1024 --vram 128       
	VBoxManage modifyvm ${vm2_name} --nic1 nat 


	echo "Conneting VM ${vm2_name} to CD ISO"
	VBoxManage storagectl ${vm2_name} --name "SATA Controller 2" --add sata --controller IntelAhci       
	VBoxManage storageattach ${vm2_name} --storagectl "SATA Controller 2" --port 0 --device 0 --type hdd --medium  ${path}/${storage_name2}                
	VBoxManage storagectl ${vm2_name} --name "IDE Controller 2" --add ide --controller PIIX4       
	VBoxManage storageattach ${vm2_name} --storagectl "IDE Controller 2" --port 1 --device 0 --type dvddrive --medium ${path}/${iso_linux}      
	VBoxManage modifyvm ${vm2_name} --boot1 dvd --boot2 disk --boot3 none --boot4 none 

	echo "Setting RDP access for the VM ${vm2_name}"
	VBoxManage modifyvm ${vm2_name} --vrde on                  
	VBoxManage modifyvm ${vm2_name} --vrdemulticon on --vrdeport 10001

	echo "${vm2_name} was create successfully"


}

function run_vms {

	echo "Starting VM ${vm1_name}"
	#VBoxHeadless --startvm ${vm1_name} 
	#VBoxManage startvm ${vm1_name} 
	VBoxManage startvm ${vm1_name} --type headless

	echo "Starting VM ${vm2_name}"
	#VBoxHeadless --startvm ${vm1_name} 
	#VBoxManage startvm ${vm1_name} 
	VBoxManage startvm ${vm2_name} --type headless

}

function listvms {
	echo "----------- VMS created ----------"
	VBoxManage list vms
	echo "----------- VMS running ----------"
	VBoxManage list runningvms
}

function poweroffvms {
	echo "----------- Shutdown VMS ----------"
	VBoxManage controlvm  ${vm1_name} poweroff
	VBoxManage controlvm  ${vm2_name} poweroff
}

function destroyvms {
	echo "----------- Destroying VMS ----------"
	VBoxManage unregistervm ${vm1_name} --delete
	VBoxManage unregistervm ${vm2_name} --delete
}

function activate_livemigration {
	echo "----------- Activating VMS ----------"
	VBoxManage modifyvm ${vm2_name} --teleporter on --teleporterport ${port}
}

function livemigration {
	echo "----------- Starting Live Migration ----------"
	VBoxManage controlvm ${vm1_name} teleport --host localhost --port ${port}
}

function metrics {

	while true
	do
		echo "----------- Metrics for CPU Load ----------"
		VBoxManage metrics query ${vm1_name} CPU/Load/User 
		VBoxManage metrics query ${vm2_name} CPU/Load/User 


		echo "----------- Metrics for RAM used ----------"
		VBoxManage metrics query ${vm1_name} RAM/Usage/Used
		VBoxManage metrics query ${vm2_name} RAM/Usage/Used
		sleep 2

		echo "**************************************************************************************************************"
	done
}


echo $command_input

#create_storage
#create_vm1
#create_vm2

#activate_livemigration #setup live migration

#run_vms

#livemigration

#listvms

#metrics


poweroffvms
destroyvms



