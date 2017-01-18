1. Copy this tool to a directory of your Linux PC.

2. Open [config.ini] and modify the configuration info in this file. 
   (Do Not modify the lines which include *****)
	
	a. update the [P4PROT] value with your own Perforce IP and Port.
       update the [P4USER] value with your own Perforce ID (Account).
	   
	b. Fill the branches you want to search.
	   Each branch need end with [/...].
	
	c. Fill the changelist range you want to search.
	   The default value of [STARTCL] and [ENDCL] is 0, it means that the toll will search all CL in these branches.
	   You can set the CL range.
	   
3. Save [config.ini] file.

4. run [miniReleaseNote.sh]. (./miniReleaseNote.sh)

5. It will export a file named as [result.txt].
   You can open it directly or copy/paste it to excel.