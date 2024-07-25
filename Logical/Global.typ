
TYPE
	gAxisControl_type : 	STRUCT 
		Status : gAxisStatus_type;
		Command : gAxisCommand_type;
		Parameters : gAxisParameters_type;
	END_STRUCT;
	gAxisStatus_type : 	STRUCT 
		PoweredOn : BOOL;
	END_STRUCT;
	gAxisCommand_type : 	STRUCT 
		PowerOn : BOOL;
		Enable : BOOL;
	END_STRUCT;
	gAxisParameters_type : 	STRUCT 
		New_Member : USINT;
	END_STRUCT;
END_TYPE
