
PROGRAM _CYCLIC

	(**** Call Subroutines ****)
	
	Act_Config;
	Act_Parameters;
	
	(**************************)
	
	
	(**** Checks is the motor is powered On ****)
	
	IF NOT gAxis[AxisIndex].Command.PowerOn THEN 
		StAxis := STATE_WAIT;
	END_IF
	
	(**** Checks the motor error ****)
	
	IF AxisBasic.Error OR AxisConfig.Error OR AxisCoupling.Error THEN 
		StAxis:= STATE_ERROR;
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
		
			IF gAxis[AxisIndex].Command.PowerOn AND NOT AxisBasic.PowerOn THEN 
				AxisBasic.Power := TRUE;
			ELSIF AxisBasic.PowerOn THEN 
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
		
			IF gAxis[AxisIndex].Command.Auto THEN 
				StAxis:= STATE_AUTO;
			END_IF
			
		STATE_AUTO:
			
			IF AxisCoupling.Info.MasterReady AND AxisCoupling.Info.SlaveReady AND gAxis[AxisIndex].Command.Auto THEN 
				AxisCoupling.Gear := TRUE;
			ELSIF NOT AxisCoupling.Info.MasterReady OR NOT AxisCoupling.Info.SlaveReady THEN
				StAxis:= STATE_ERROR;
			ELSIF NOT gAxis[AxisIndex].Command.Auto THEN
				
				AxisCoupling.Gear := FALSE;
				
				IF NOT AxisCoupling.InSync THEN
					StAxis:= STATE_READY;
				END_IF
				
			END_IF
		
		STATE_ERROR:
		
				
		
	END_CASE
	
	
	(********** Call FB's **********)
	
	AxisBasic();
	AxisConfig();
	AxisCoupling();
	ReadAxisError();
	
 	(*******************************)
END_PROGRAM
