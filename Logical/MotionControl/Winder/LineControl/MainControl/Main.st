
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	(**** control de errores ****)
	
	FOR ErrorIndex := 0 TO MAX_AXIS DO
		
		IF gAxis[ErrorIndex].Status.Error THEN 
			StLineCtrl := STATE_ERROR;
		END_IF
		
	END_FOR
	
	(**** Detener proceso  ****)
	
	IF Stop THEN 
		StLineCtrl := STATE_STOP;
	END_IF
	
	(**** Secuencia Line control  ****)
	
	CASE StLineCtrl OF
		
		STATE_WAIT:
			
			FOR i:= 0 TO MAX_AXIS DO
				
				IF gAxis[i].Status.Active THEN 
					StLineCtrl:= STATE_POWER_ON;
				END_IF
			END_FOR
			
		STATE_POWER_ON:
			
			FOR i := 0 TO MAX_AXIS DO
						
				gAxis[i].Command.PowerOn := TRUE;
				
				IF gAxis[i].Status.PoweredOn THEN
					StLineCtrl:= STATE_HOME;
				END_IF
				
			END_FOR
				
		STATE_HOME:
		
			FOR i := 0 TO MAX_AXIS DO
				
				IF gAxis[i].Status.Homed THEN 
					StLineCtrl:= STATE_READY;
				END_IF
				
			END_FOR
	
		STATE_READY:
		
			IF Auto THEN 
				StLineCtrl := STATE_AUTO;
			END_IF
		
		STATE_AUTO:
			
			
			FOR i := 0 TO MAX_AXIS DO
				
				gAxis[i].Command.Auto := TRUE;
				gAxis[VMASTER].Command.Start := Start AND gAxis[i<>VMASTER].Status.Auto;
		
				IF NOT Auto THEN 
					gAxis[i].Command.Auto := FALSE;
					StLineCtrl	:= STATE_READY;
				END_IF
				
			END_FOR
		
		STATE_ERROR:
			
			gAxis[VMASTER].Command.Start := FALSE;
			
			FOR i:= 0 TO MAX_AXIS DO
				
				gAxis[i].Command.Auto 	:= FALSE;
				gAxis[i].Command.Manual := FALSE;
				gAxis[i].Command.Reset  := EDGEPOS(Reset);
				gAxis[VMASTER].Command.Start	:= FALSE;
				
				IF NOT gAxis[i].Status.Error AND gAxis[i].Command.Reset THEN 
					StLineCtrl := STATE_READY;
				END_IF
				
			END_FOR
		
		STATE_STOP :
		
			gAxis[VMASTER].Command.Stop :=  TRUE;
		
			IF gAxis[VMASTER].Status.Stop THEN 
				gAxis[VMASTER].Command.Stop :=  FALSE;
				StLineCtrl := STATE_READY;
			END_IF
		
		
		
	END_CASE
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

