
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	
	
	(**** Line control Sequence ****)
	
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
		
				IF NOT Auto THEN 
					gAxis[i].Command.Auto := FALSE;
					StLineCtrl	:= STATE_READY;
				END_IF
				
			END_FOR
		
		
			
	END_CASE
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

