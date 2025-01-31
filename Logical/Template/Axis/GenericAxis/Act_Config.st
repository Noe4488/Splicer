
ACTION Act_Config: 
	
	gAxis[AxisIndex].Status.Active 			:= AxisBasic.Active;
	gAxis[AxisIndex].Status.PoweredOn 	:= AxisBasic.PowerOn;
	gAxis[AxisIndex].Status.Homed				:= AxisBasic.IsHomed;
	gAxis[AxisIndex].Status.Auto 				:= AxisCoupling.InSync;
	gAxis[AxisIndex].Status.Error 			:= AxisBasic.Error OR AxisConfig.Error OR AxisCoupling.Error;
	
	AxisBasic.Enable 				:= gAxis[AxisIndex].Command.Enable;
	AxisCoupling.Enable 		:= AxisBasic.Active;
	AxisConfig.Enable 			:= AxisBasic.Active;
	ReadAxisError.Enable 		:= AxisBasic.Error;
	
	IF gAxis[AxisIndex].Command.Reset THEN 
		AxisBasic.ErrorReset := TRUE;
		AxisCoupling.ErrorReset := TRUE;
		AxisConfig.ErrorReset := TRUE;
	ELSE
		AxisBasic.ErrorReset := FALSE;
		AxisCoupling.ErrorReset := FALSE;
		AxisConfig.ErrorReset := FALSE;
	END_IF
	
	
	(**** Definicion sentido de giro del eje *****)
	
	IF AxisDirection THEN
		Direction	:= mpAXIS_DIR_CLOCKWISE;
	ELSE
		Direction	:= mpAXIS_DIR_COUNTERCLOCKWISE;
	END_IF
	
	(**** Configuracion AxisCoupling *****)
	
	AxisCouplingPar.RatioNumerator 		:= 1;
	AxisCouplingPar.RatioDenominator 	:= 1;
	AxisCouplingPar.Gear.Acceleration;
	AxisCouplingPar.Gear.Deceleration;
	
	(**** Configuracion FB Read Axis Error ****)
	
	ReadAxisError.Configuration.Format := mcWRAP;   //ReadAxisErrorPar;
	ReadAxisError.Configuration.LineLength := SIZEOF(ErrorText[0]);
	ReadAxisError.Configuration.DataLength := SIZEOF(ErrorText);
	ReadAxisError.Configuration.DataAddress := ADR(ErrorText[0]);
	ReadAxisError.Configuration.DataObjectName := 'acp10etxen';
	
	(**** Secuencia configuarcion Eje *****)
	
	IF NOT ConfigReq THEN 
		StConfig := CONFIG_WAIT;
	END_IF
	
	CASE StConfig OF
		
		CONFIG_WAIT:
		
			IF ConfigReq THEN 
				StConfig := CONFIG_LOAD_REQ;
			END_IF
			
		CONFIG_LOAD_REQ:
					
			(* Carga la configuracion por default en Confing.mpaxisbasic*)
				
			AxisConfig.Load	:= TRUE;
						
			IF AxisConfig.CommandDone THEN 
				StConfig := CONFIG_LOAD_DONE;
			END_IF
			
			
		CONFIG_LOAD_DONE:
					
			(* Actualiza la configuracion, carga parametros asignados por el usuario *)
					
			AxisConfig.Load	:= FALSE;
			StConfig := CONFIG_SAVE_REQ;
					
		CONFIG_SAVE_REQ:
			
			AxisConfigPar.AxisName := AxisName ;
		
			//Axis
			AxisConfigPar.Axis.BaseType 				:= mpAXIS_PERIODIC_ROTARY;
			AxisConfigPar.Axis.MeasurementUnit 			:= mpAXIS_UNIT_GENERIC;
			AxisConfigPar.Axis.MeasurementResolution 	:= Resolution;
			AxisConfigPar.Axis.PeriodSettings.Period	:= Period;  
			
			AxisConfigPar.Axis.MovementLimits.VelocityPositive	:= LimitSpeed;
			AxisConfigPar.Axis.MovementLimits.VelocityNegative	:= LimitSpeed;
			AxisConfigPar.Axis.MovementLimits.Acceleration		:= LimitAccDec;
			AxisConfigPar.Axis.MovementLimits.Deceleration		:= LimitAccDec;
	
			//Drive
			AxisConfigPar.Drive.Gearbox.Input			:= GearIn;
			AxisConfigPar.Drive.Gearbox.Output			:= GearOut;
			AxisConfigPar.Drive.Gearbox.Direction 		:= Direction;
			AxisConfigPar.Drive.Transformation.ReferenceDistance := Period * SectorNumber;
				
			(* Salva en el drive los parametros asignados por el usuario *)
					
			AxisConfig.Save := TRUE;
				
			IF AxisConfig.CommandDone THEN 
				StConfig := CONFIG_SAVE_DONE;
			END_IF
				
		CONFIG_SAVE_DONE:
					
			(* Configuracion terminada *)
					
			AxisConfig.Save := FALSE;
			ConfigReq		:= FALSE;	
			ConfigDone		:= TRUE;
		
	END_CASE
	
	
	(********** FB's Configuration *********)
	
	AxisBasic.Axis 					:= Axis;
	AxisBasic.MpLink 				:= ADR(MpLink);
	AxisBasic.Parameters 		:= ADR(AxisBasicPar);
	
	AxisConfig.MpLink 				:= ADR(MpLink);
	AxisConfig.Configuration 	:= ADR(AxisConfigPar);
	
	
	AxisCoupling.MpLink				:= ADR(MpLink);
	AxisCoupling.MpLinkMaster	:= ADR(MpLinkMaster);
	AxisCoupling.Parameters		:= ADR(AxisCouplingPar);
	
	ReadAxisError.Axis := Axis;
	ReadAxisError.Mode := mcTEXT;

	
	(****************************************)


END_ACTION
