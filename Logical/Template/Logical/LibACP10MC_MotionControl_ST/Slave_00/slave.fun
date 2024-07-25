(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: Slave_00
 * File: Slave_00.fun
 * Author: reischlj
 * Created: March 09, 2011
 ********************************************************************
 * Functions and function blocks of program Slave_00
 ********************************************************************)

FUNCTION Labeler : BOOL
	VAR_INPUT
		Axis : UDINT;
	END_VAR
	VAR_IN_OUT
		AutData : MC_AUTDATA_TYP;
	END_VAR
END_FUNCTION

FUNCTION CrossCutter : BOOL
	VAR_INPUT
		Axis : UDINT;
	END_VAR
	VAR_IN_OUT
		AutData : MC_AUTDATA_TYP;
	END_VAR
END_FUNCTION

FUNCTION FlyingSaw : BOOL
	VAR_INPUT
		Axis  : UDINT;
	END_VAR
	VAR_IN_OUT
		AutData : MC_AUTDATA_TYP;
	END_VAR
END_FUNCTION
