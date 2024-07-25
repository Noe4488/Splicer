(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: ErrorHandling
 * File: errorHandlingCyclic.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program Errorhandling
 ********************************************************************)

PROGRAM _CYCLIC

(******************************ERROR_CHECK***************************)
(* check if one of the used FBs reports an error *)
IF ((MC_BR_AxisErrorCollector_0.Error = TRUE) OR (MC_Reset_0.Error = TRUE)) THEN
    ErrorStep := STATE_INTERNAL_ERROR;
END_IF

FOR configAxisIndex := 0 TO TOTAL_AXES BY 1 DO
    IF ((MC_BR_ReadAxisError_0[configAxisIndex].Error = TRUE) OR (MC_ReadStatus_0[configAxisIndex].Error = TRUE)) THEN
        ErrorStep := STATE_INTERNAL_ERROR;
        EXIT;
    END_IF
END_FOR


CASE ErrorStep OF

(**************************** CONFIGURATE_FBS ***********************)
    STATE_CONFIG_FBS: (* configurate the used FBs for the error handling *)
        MC_BR_AxisErrorCollector_0.Axis := mcALL_AXES;
        MC_BR_AxisErrorCollector_0.Enable := TRUE;

        (* configuration the MC_BR_ReadAxisError_0-FBs for all single axes *)
        FOR axisIndex := 0 TO (AXIS_MAX_INDEX) BY 1 DO
            MC_BR_ReadAxisError_0[axisIndex].Axis := AxisRef[axisIndex];
            MC_BR_ReadAxisError_0[axisIndex].Enable := TRUE;
            MC_BR_ReadAxisError_0[axisIndex].Configuration.Format := mcWRAP;
            MC_BR_ReadAxisError_0[axisIndex].Configuration.LineLength := SIZEOF(Axis[axisIndex].Error.ErrorText[0]);
            MC_BR_ReadAxisError_0[axisIndex].Configuration.DataLength := SIZEOF(Axis[axisIndex].Error.ErrorText);
            MC_BR_ReadAxisError_0[axisIndex].Configuration.DataAddress := ADR(Axis[axisIndex].Error.ErrorText[0]);
            MC_BR_ReadAxisError_0[axisIndex].Configuration.DataObjectName :='acp10etxen';
            MC_BR_ReadAxisError_0[axisIndex].Mode := mcTEXT;

            MC_ReadStatus_0[axisIndex].Axis := AxisRef[axisIndex];
            MC_ReadStatus_0[axisIndex].Enable := TRUE;
        END_FOR

        (* configuration the MC_BR_ReadAxisError_0-FBs for all master axes *)
        FOR masterIndex := 0 TO (MASTER_MAX_INDEX) BY 1 DO
            MC_BR_ReadAxisError_0[masterIndex+AXIS_NUMBER].Axis := MasterRef[masterIndex];
            MC_BR_ReadAxisError_0[masterIndex+AXIS_NUMBER].Enable := TRUE;
            MC_BR_ReadAxisError_0[masterIndex+AXIS_NUMBER].Configuration.Format := mcWRAP;
            MC_BR_ReadAxisError_0[masterIndex+AXIS_NUMBER].Configuration.LineLength := SIZEOF(Master[masterIndex].Error.ErrorText[0]);
            MC_BR_ReadAxisError_0[masterIndex+AXIS_NUMBER].Configuration.DataLength := SIZEOF(Master[masterIndex].Error.ErrorText);
            MC_BR_ReadAxisError_0[masterIndex+AXIS_NUMBER].Configuration.DataAddress := ADR(Master[masterIndex].Error.ErrorText[0]);
            MC_BR_ReadAxisError_0[masterIndex+AXIS_NUMBER].Configuration.DataObjectName := 'acp10etxen';
            MC_BR_ReadAxisError_0[masterIndex+AXIS_NUMBER].Mode := mcTEXT;

            MC_ReadStatus_0[masterIndex+AXIS_NUMBER].Axis := MasterRef[masterIndex];
            MC_ReadStatus_0[masterIndex+AXIS_NUMBER].Enable := TRUE;
        END_FOR

        (* configuration the MC_BR_ReadAxisError_0-FBs for all slave axes *)
        FOR slaveIndex := 0 TO (SLAVE_MAX_INDEX) BY 1 DO
            MC_BR_ReadAxisError_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Axis := SlaveRef[slaveIndex];
            MC_BR_ReadAxisError_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Enable := TRUE;
            MC_BR_ReadAxisError_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Configuration.Format := mcWRAP;
            MC_BR_ReadAxisError_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Configuration.LineLength := SIZEOF(Slave[slaveIndex].Error.ErrorText[0]);
            MC_BR_ReadAxisError_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Configuration.DataLength := SIZEOF(Slave[slaveIndex].Error.ErrorText);
            MC_BR_ReadAxisError_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Configuration.DataAddress := ADR(Slave[slaveIndex].Error.ErrorText[0]);
            MC_BR_ReadAxisError_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Configuration.DataObjectName := 'acp10etxen';
            MC_BR_ReadAxisError_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Mode := mcTEXT;

            MC_ReadStatus_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Axis := SlaveRef[slaveIndex];
            MC_ReadStatus_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Enable := TRUE;
        END_FOR

        (* configuration the MC_BR_ReadAxisError_0-FBs for all power supply module *)
        FOR psmIndex := 0 TO (PSM_MAX_INDEX) BY 1 DO
            MC_BR_ReadAxisError_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Axis := PsmRef[psmIndex];
            MC_BR_ReadAxisError_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Enable := TRUE;
            MC_BR_ReadAxisError_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Configuration.Format := mcWRAP;
            MC_BR_ReadAxisError_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Configuration.LineLength := SIZEOF(PowerSupply[psmIndex].Error.ErrorText[0]);
            MC_BR_ReadAxisError_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Configuration.DataLength := SIZEOF(PowerSupply[psmIndex].Error.ErrorText);
            MC_BR_ReadAxisError_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Configuration.DataAddress := ADR(PowerSupply[psmIndex].Error.ErrorText[0]);
            MC_BR_ReadAxisError_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Configuration.DataObjectName := 'acp10etxen';
            MC_BR_ReadAxisError_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Mode := mcTEXT;

            MC_ReadStatus_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Axis := PsmRef[psmIndex];
            MC_ReadStatus_0[psmIndex+AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER].Enable := TRUE;
        END_FOR

        ErrorStep := STATE_WAIT;
        AcknowledgeStep := STATE_ERROR_SCAN;

        (* End of STATE_CONFIG_FBS *)

(*************************** CHECK_AXES_FOR_ERROR *******************)
    STATE_WAIT: (* check if at least on one of the axes an error occured *)
        IF ((MC_BR_AxisErrorCollector_0.AxisError = TRUE) OR
            (MC_BR_AxisErrorCollector_0.AxisWarning = TRUE) OR 
            (MC_BR_AxisErrorCollector_0.FunctionBlockError = TRUE) OR
            (MC_BR_AxisErrorCollector_0.Errorstop = TRUE)) THEN
              ErrorStep := STATE_ERROR_HANDLING;
        ELSE
            GlobalError.AxisTyp := '';
            GlobalError.AxisIndex := 0;
            GlobalError.ErrorRecord.Info := 0;
            GlobalError.ErrorRecord.Number := 0;
            GlobalError.ErrorRecord.ParID := 0;
            GlobalError.ErrorText[0] := '';
            GlobalError.ErrorText[1] := '';
            GlobalError.ErrorText[2] := '';
            GlobalError.ErrorText[3] := ''; 
        END_IF

        (* End of STATE_WAIT *)

(**************************** HANDLE_ACTIVE_ERRORS ******************)
    STATE_ERROR_HANDLING: (* check witch axis is in ErrorStop and withc axes has to be stopped *)
        (* check if a single axis has to be stopped *)
        FOR axisIndex := 0 TO (AXIS_MAX_INDEX) BY 1 DO
            IF (MC_ReadStatus_0[axisIndex].Errorstop = TRUE) THEN
                Axis[axisIndex].Command.Stop := TRUE;
            END_IF
        END_FOR

        (* check if the master slave combination has to be stopped *)
        FOR masterIndex := 0 TO (MASTER_MAX_INDEX) BY 1 DO
            IF (MC_ReadStatus_0[masterIndex+AXIS_NUMBER].Errorstop = TRUE) THEN
                FOR masterIndex := 0 TO (MASTER_MAX_INDEX) BY 1 DO
                    Master[masterIndex].Command.Stop := TRUE;
                END_FOR

                FOR slaveIndex := 0 TO (SLAVE_MAX_INDEX) BY 1 DO
                    Slave[slaveIndex].Command.Stop := TRUE;
                END_FOR
            END_IF
        END_FOR

        (* check if the master slave combination has to be stopped *)
        FOR slaveIndex := 0 TO (SLAVE_MAX_INDEX) BY 1 DO
            IF  (MC_ReadStatus_0[slaveIndex+AXIS_NUMBER+MASTER_NUMBER].Errorstop = TRUE) THEN
                FOR masterIndex := 0 TO (MASTER_MAX_INDEX) BY 1 DO
                    Master[masterIndex].Command.Stop := TRUE;
                END_FOR

                FOR slaveIndex := 0 TO (SLAVE_MAX_INDEX) BY 1 DO
                    Slave[slaveIndex].Command.Stop := TRUE;
                END_FOR
            END_IF
        END_FOR

    (******************* STEP_SEQUENCE OF ERROR ACKNOWLEDGE *************)
    CASE AcknowledgeStep OF
        (************************** SEARCH FOR ERRORS ***********************)
        STATE_ERROR_SCAN: (* check if an error is active on one of the axis *)
            ErrorStep := STATE_WAIT;
            FOR totalAxisIndex := 0 TO (TOTAL_AXES-1) BY 1 DO
                IF ((MC_BR_ReadAxisError_0[totalAxisIndex].AxisErrorCount > 0) OR
                    (MC_BR_ReadAxisError_0[totalAxisIndex].AxisWarningCount > 0) OR
                    (MC_BR_ReadAxisError_0[totalAxisIndex].FunctionBlockErrorCount > 0)) THEN
                    AcknowledgeStep := STATE_ERROR_ACKNOWLEDGE;
                    ErrorStep := STATE_ERROR_HANDLING;
                    EXIT;
                ELSIF (MC_ReadStatus_0[totalAxisIndex].Errorstop = TRUE) THEN
                    AcknowledgeStep := STATE_RESET;
                    ErrorStep := STATE_ERROR_HANDLING;
                    EXIT;
                END_IF
            END_FOR

            (* End of STATE_ERROR_SCAN *)

        (********************** WAIT FOR ACKNOWLEDGE ************************)
        STATE_ERROR_ACKNOWLEDGE:
            (* copy the actual error information to the global error structure *)
            IF (totalAxisIndex < AXIS_NUMBER) THEN
                GlobalError.AxisTyp := 'Axis';
                GlobalError.ErrorText := Axis[totalAxisIndex].Error.ErrorText;
                GlobalError.ErrorRecord := Axis[totalAxisIndex].Error.ErrorRecord;
            ELSIF (totalAxisIndex < (AXIS_NUMBER+MASTER_NUMBER)) THEN
                GlobalError.AxisTyp := 'Master';
                GlobalError.ErrorText := Master[totalAxisIndex-AXIS_NUMBER].Error.ErrorText;
                GlobalError.ErrorRecord := Master[totalAxisIndex-AXIS_NUMBER].Error.ErrorRecord;
            ELSIF (totalAxisIndex < (AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)) THEN
                GlobalError.AxisTyp := 'Slave';
                GlobalError.ErrorText := Slave[totalAxisIndex-(AXIS_NUMBER+MASTER_NUMBER)].Error.ErrorText;
                GlobalError.ErrorRecord := Slave[totalAxisIndex-(AXIS_NUMBER+MASTER_NUMBER)].Error.ErrorRecord;
            ELSIF (totalAxisIndex < (AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER+PSM_NUMBER)) THEN
                GlobalError.AxisTyp := 'PSM';
                GlobalError.ErrorText := PowerSupply[totalAxisIndex-(AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)].Error.ErrorText;
                GlobalError.ErrorRecord := PowerSupply[totalAxisIndex-(AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)].Error.ErrorRecord;
            END_IF
            GlobalError.AxisIndex := totalAxisIndex;

            IF (GlobalCommand.ErrorAcknowledge = TRUE) THEN
                GlobalCommand.ErrorAcknowledge := FALSE;
                MC_BR_ReadAxisError_0[totalAxisIndex].Acknowledge := TRUE;
            ELSIF (MC_BR_ReadAxisError_0[totalAxisIndex].Acknowledge = TRUE) THEN
                MC_BR_ReadAxisError_0[totalAxisIndex].Acknowledge := FALSE;
                AcknowledgeStep := STATE_ERROR_SCAN;
            END_IF

            (* End of STATE_ERROR_ACKNOWLEDGE *)

        (************************* RESET AXES IN ERRORSTEP ******************)
        STATE_RESET:
            IF (totalAxisIndex < AXIS_NUMBER) THEN
                MC_Reset_0.Axis := AxisRef[totalAxisIndex];
            ELSIF (totalAxisIndex < (AXIS_NUMBER+MASTER_NUMBER)) THEN
                MC_Reset_0.Axis := MasterRef[totalAxisIndex-AXIS_NUMBER];
            ELSIF (totalAxisIndex < (AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)) THEN
                MC_Reset_0.Axis := SlaveRef[totalAxisIndex-(AXIS_NUMBER+MASTER_NUMBER)];
            ELSE
                MC_Reset_0.Axis := PsmRef[totalAxisIndex-(AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)];
            END_IF
            MC_Reset_0.Execute := TRUE;

            IF (MC_Reset_0.Done = TRUE) THEN
                MC_Reset_0.Execute := 0;
                AcknowledgeStep := STATE_ERROR_SCAN;
            END_IF

            (* End of STATE_RESET *)
    END_CASE
    (************* END OF STEP SEQUENCE OF ERROR ACKNOWLEDGE ************)

    (* End of STATE_ERROR_HANDLING *)

(****************** DEACTIVATE USED FBS IN CASE OF ERROR ************)
    STATE_INTERNAL_ERROR:
        MC_BR_AxisErrorCollector_0.Enable := FALSE;
        MC_Reset_0.Execute := FALSE;

        FOR configAxisIndex := 0 TO (TOTAL_AXES-1) BY 1 DO
            MC_BR_ReadAxisError_0[configAxisIndex].Enable := FALSE;
            MC_ReadStatus_0[configAxisIndex].Enable := FALSE;
        END_FOR

        ErrorStep := STATE_CONFIG_FBS;

        (* End of STATE_INTERNAL_ERROR *)

END_CASE

(************************** CALL FBS ********************************)
MC_BR_AxisErrorCollector_0();

FOR configAxisIndex := 0 TO TOTAL_AXES BY 1 DO
    MC_BR_ReadAxisError_0[configAxisIndex]();
    IF (configAxisIndex < AXIS_NUMBER) THEN
        Axis[configAxisIndex].Error.AxisErrorCount := MC_BR_ReadAxisError_0[configAxisIndex].AxisErrorCount;
        Axis[configAxisIndex].Error.AxisWarningCount := MC_BR_ReadAxisError_0[configAxisIndex].AxisWarningCount;
        Axis[configAxisIndex].Error.FunctionBlockErrorCount := MC_BR_ReadAxisError_0[configAxisIndex].FunctionBlockErrorCount;
        Axis[configAxisIndex].Error.ErrorRecord := MC_BR_ReadAxisError_0[configAxisIndex].ErrorRecord;
    ELSIF (configAxisIndex < (AXIS_NUMBER+MASTER_NUMBER)) THEN
        Master[configAxisIndex-AXIS_NUMBER].Error.AxisErrorCount := MC_BR_ReadAxisError_0[configAxisIndex].AxisErrorCount;
        Master[configAxisIndex-AXIS_NUMBER].Error.AxisWarningCount := MC_BR_ReadAxisError_0[configAxisIndex].AxisWarningCount;
        Master[configAxisIndex-AXIS_NUMBER].Error.FunctionBlockErrorCount := MC_BR_ReadAxisError_0[configAxisIndex].FunctionBlockErrorCount;
        Master[configAxisIndex-AXIS_NUMBER].Error.ErrorRecord := MC_BR_ReadAxisError_0[configAxisIndex].ErrorRecord;
	ELSIF (configAxisIndex < (AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)) THEN    
		Slave[configAxisIndex-(AXIS_NUMBER+MASTER_NUMBER)].Error.AxisErrorCount := MC_BR_ReadAxisError_0[configAxisIndex].AxisErrorCount;
		Slave[configAxisIndex-(AXIS_NUMBER+MASTER_NUMBER)].Error.AxisWarningCount := MC_BR_ReadAxisError_0[configAxisIndex].AxisWarningCount;
		Slave[configAxisIndex-(AXIS_NUMBER+MASTER_NUMBER)].Error.FunctionBlockErrorCount := MC_BR_ReadAxisError_0[configAxisIndex].FunctionBlockErrorCount;
		Slave[configAxisIndex-(AXIS_NUMBER+MASTER_NUMBER)].Error.ErrorRecord := MC_BR_ReadAxisError_0[configAxisIndex].ErrorRecord;		
	ELSIF (configAxisIndex < (AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER+PSM_NUMBER)) THEN			
		PowerSupply[configAxisIndex-(AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)].Error.AxisErrorCount := MC_BR_ReadAxisError_0[configAxisIndex].AxisErrorCount;
        PowerSupply[configAxisIndex-(AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)].Error.AxisWarningCount := MC_BR_ReadAxisError_0[configAxisIndex].AxisWarningCount;
        PowerSupply[configAxisIndex-(AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)].Error.FunctionBlockErrorCount := MC_BR_ReadAxisError_0[configAxisIndex].FunctionBlockErrorCount;
        PowerSupply[configAxisIndex-(AXIS_NUMBER+MASTER_NUMBER+SLAVE_NUMBER)].Error.ErrorRecord := MC_BR_ReadAxisError_0[configAxisIndex].ErrorRecord;
    END_IF
    MC_ReadStatus_0[configAxisIndex]();
END_FOR

MC_Reset_0();

END_PROGRAM
