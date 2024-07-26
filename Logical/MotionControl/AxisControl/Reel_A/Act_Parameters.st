
ACTION Act_Parameters:
	
	//---- Numero del Eje ----///
	AxisIndex := REEL_A;
	
	//---- MpLink ----//
	
	Axis 			:= ADR(gAxReel_A);
	MpLinkMaster    := gVMasterLink;
	MpLink 			:= gAxReelA_Link;
	
	//---- Nombre del eje ----//
	AxisName := 'Reel A';
	
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
	
	// ---- Definicion Paramentros de posicion del eje ----//
	HeadNumber 			:= 1;
	Period 				:= 360.0 * HeadNumber;
	SectorNumber 		:= 1;
	Resolution			:= 0.01;
	/////////////////////////////////////////////////////////////////

END_ACTION
