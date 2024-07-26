
PROGRAM _CYCLIC

	(**** Call Subroutines ****)
	
	Act_Config;
	Act_Parameters;
	
	(**************************)
	
	//--- Checks is the motor is powered On
	
	IF NOT gAxis[AxisIndex].Command.PowerOn THEN 
		StAxis := STATE_WAIT;
	END_IF
	
	
	(**** Axis Sequencer ****)
	
	CASE StAxis OF
		
		STATE_WAIT:
			
			IF AxisBasic.Active AND AxisBasic.Info.BootState = mpAXIS_BLP_DONE AND AxisBasic.Info.ReadyToPowerOn AND ConfigDone THEN
				StAxis:= STATE_POWER_ON;
			ELSIF gAxis[AxisIndex].Command.PowerOn AND NOT ConfigDone THEN 
				ConfigReq:= TRUE;
			END_IF
			
		STATE_POWER_ON:
		
			IF AxisBasic.Info.HardwareInfo.DeviceType = mpAXIS_VIRTUAL THEN 
				StAxis:= STATE_HOME;
			END_IF
		
		STATE_HOME:
		
			IF NOT AxisBasic.IsHomed THEN 
				AxisBasic.Home := TRUE;
			ELSIF AxisBasic.IsHomed THEN 
				AxisBasic.Home := FALSE;
				StAxis:= STATE_READY;
			END_IF
		
		STATE_READY:
		
		
	END_CASE
	
	gAxis[AxisIndex].Status.Active := AxisBasic.Active;
	gAxis[AxisIndex].Status.PoweredOn := AxisBasic.PowerOn;
	gAxis[AxisIndex].Status.Homed:= AxisBasic.IsHomed;
	
	(********** Call FB's **********)
	
	AxisBasic();
	AxisConfig();
	
	(*******************************)
END_PROGRAM
