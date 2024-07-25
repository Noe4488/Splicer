
ACTION Act_Config: 
	
	//---- Numero del Eje ----///
	AxisIndex := GENERIC;
	
	//---- MpLink ----//
	MpLink 			:= gTemplateLink;
	Axis 			:= ADR(gAxTemplate);
	//MpLinkMaster;
	
	//---- Nombre del eje ----//
	AxisName := 'Eje Generico';
	
	//---- Hablita el eje ----//
	gAxis[AxisIndex].Command.Enable := TRUE; // ESTE DATA DEBERA SER USADO EN UN VARIABLE DE LA CONFIGURACION MAQUINA PARA HABILITAR O DESHABILITAR UN EJE.
	
	//---- Limite de velocidad -----//
	LimitSpeed 	:= 6600.0;
	
	//----- Limete de aceleracion/desaceleracion ----//
	LimitAccDec := 6600.0;
	
	//---- Relacion de velocoidad motor/reductor ----// 
	GearIn 	:= 1;
	GearOut := 1;
	
	//---- Seleccion direccion de rotacion del eje ----//
	AxisDirection := TRUE; // TRUE = sentido de las manesillas del reloj; FALSE = en contra de las manesillas del reloj;
	
	// ---- Definicion sentido de giro del eje ----//
	IF AxisDirection THEN
		Direction	:= mpAXIS_DIR_CLOCKWISE;
	ELSE
		Direction	:= mpAXIS_DIR_COUNTERCLOCKWISE;
	END_IF
	
	// ---- Definicion Paramentros de posicion del eje ----//
	HeadNumber 			:= 1;
	Period 				:= 360.0 * HeadNumber;
	SectorNumber 		:= 1;
	Resolution			:= 0.01;
	/////////////////////////////////////////////////////////////////
	
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
	
	//	gAxis[AxisIndex].Cmd.ConfigReq := StConfig = CONFIG_LOAD_REQ;
	//	gAxis[AxisIndex].Sts.ConfigDone := StConfig = CONFIG_SAVE_DONE;
	
	AxisBasic.Enable 	:= gAxis[AxisIndex].Command.Enable;
	AxisConfig.Enable 	:= AxisBasic.Active;
	
	(********** FB's Configuration *********)
	
	AxisBasic.Axis 		:= Axis;
	AxisBasic.MpLink 	:= ADR(MpLink);
	AxisBasic.Parameters := ADR(AxisBasicPar);
	
	AxisConfig.MpLink 			:= ADR(MpLink);
	AxisConfig.Configuration 	:= ADR(AxisConfigPar);
	
	
	//	AxisCam.MpLink				:= ADR(MpLink);
	//	AxisCam.MpLinkMaster		:= ADR(MpLinkMaster);
	//	AxisCam.Parameters			:= ADR(AxisCamPar);
	
	(****************************************)


END_ACTION
