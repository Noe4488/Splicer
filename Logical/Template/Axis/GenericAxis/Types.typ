
TYPE
	AxisState_enum : 
		(
		STATE_WAIT := 0,
		STATE_POWER_ON := 10,
		STATE_STOP := 20,
		STATE_READY := 30,
		STATE_HOME := 40,
		STATE_AUTO := 50,
		STATE_MANUAL := 60,
		STATE_MAINT := 70,
		STATE_ERROR := 999
		);
	ConfigStates_enum : 
		(
		CONFIG_WAIT := 0,
		CONFIG_LOAD_REQ := 10,
		CONFIG_LOAD_DONE := 20,
		CONFIG_SAVE_REQ := 30,
		CONFIG_SAVE_DONE := 70
		);
END_TYPE
