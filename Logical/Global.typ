
TYPE
	gAxisControl_type : 	STRUCT 
		Status : gAxisStatus_type;
		Command : gAxisCommand_type;
		Parameters : gAxisParameters_type;
	END_STRUCT;
	gAxisStatus_type : 	STRUCT 
		PoweredOn : BOOL;
		Homed : BOOL;
		Error : BOOL;
		Active : BOOL;
		Auto : BOOL;
		Stop : BOOL;
	END_STRUCT;
	gAxisCommand_type : 	STRUCT 
		PowerOn : BOOL;
		Enable : BOOL;
		Auto : BOOL;
		Manual : BOOL;
		Start : BOOL;
		Stop : BOOL;
		Reset : BOOL;
	END_STRUCT;
	gAxisParameters_type : 	STRUCT 
		Speed : REAL;
		Acc : REAL;
		Decel : REAL;
		Position : REAL;
	END_STRUCT;
END_TYPE
