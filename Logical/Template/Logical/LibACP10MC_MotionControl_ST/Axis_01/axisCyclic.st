(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: Axis_00
 * File: axisCyclic.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program Axis_00
 ********************************************************************)

PROGRAM _CYCLIC

(*********** CHECK IF POWER SHOULD BE OFF ***************************)
    IF ((GlobalCommand.Power = FALSE) AND (Axis[AXIS_INDEX].Command.Power = FALSE)) THEN
        AxisStep := STATE_WAIT;
    END_IF

    (* central monitoring of the stop command allows a shorter reaction time *)
    IF ((GlobalCommand.Stop = TRUE) OR (Axis[AXIS_INDEX].Command.Stop = TRUE)) THEN
        IF ((GlobalCommand.Power = TRUE) OR (Axis[AXIS_INDEX].Command.Power = TRUE)) THEN
            AxisStep := STATE_STOP;
            (* reset all FB execute inputs we use *)
            MC_Home_0.Execute := FALSE;
            MC_Halt_0.Execute := FALSE;
            MC_MoveAbsolute_0.Execute := FALSE;
            MC_MoveAdditive_0.Execute := FALSE;
            MC_MoveVelocity_0.Execute := FALSE;
            
            Axis[AXIS_INDEX].Command.MoveJogPos := FALSE;
            Axis[AXIS_INDEX].Command.MoveJogNeg := FALSE;
        END_IF
    END_IF

(************************** MC_READSTATUS ***************************)
MC_ReadStatus_0.Enable := NOT(MC_ReadStatus_0.Error);
MC_ReadStatus_0.Axis := AxisRef[AXIS_INDEX];
MC_ReadStatus_0();
Axis[AXIS_INDEX].AxisState.Disabled             := MC_ReadStatus_0.Disabled;
Axis[AXIS_INDEX].AxisState.StandStill           := MC_ReadStatus_0.StandStill;
Axis[AXIS_INDEX].AxisState.Stopping             := MC_ReadStatus_0.Stopping;
Axis[AXIS_INDEX].AxisState.Homing               := MC_ReadStatus_0.Homing;
Axis[AXIS_INDEX].AxisState.DiscreteMotion       := MC_ReadStatus_0.DiscreteMotion;
Axis[AXIS_INDEX].AxisState.ContinuousMotion     := MC_ReadStatus_0.ContinuousMotion;
Axis[AXIS_INDEX].AxisState.SynchronizedMotion   := MC_ReadStatus_0.SynchronizedMotion;
Axis[AXIS_INDEX].AxisState.ErrorStop            := MC_ReadStatus_0.Errorstop;

(********************** MC_BR_READDRIVESTATUS ***********************)
MC_BR_ReadDriveStatus_0.Enable := NOT(MC_BR_ReadDriveStatus_0.Error);
MC_BR_ReadDriveStatus_0.Axis := AxisRef[AXIS_INDEX];
MC_BR_ReadDriveStatus_0.AdrDriveStatus := ADR(Axis[AXIS_INDEX].Status.DriveStatus);
MC_BR_ReadDriveStatus_0();

(********************* MC_READACTUALPOSITION ************************)
MC_ReadActualPosition_0.Enable := NOT(MC_ReadActualPosition_0.Error);
MC_ReadActualPosition_0.Axis := AxisRef[AXIS_INDEX];
MC_ReadActualPosition_0();
IF(MC_ReadActualPosition_0.Valid = TRUE) THEN
    Axis[AXIS_INDEX].Status.ActPosition := MC_ReadActualPosition_0.Position;
END_IF

(********************* MC_READACTUALVELOCITY ************************)
MC_ReadActualVelocity_0.Enable := NOT(MC_ReadActualVelocity_0.Error);
MC_ReadActualVelocity_0.Axis := AxisRef[AXIS_INDEX];
MC_ReadActualVelocity_0();
IF(MC_ReadActualVelocity_0.Valid = TRUE) THEN
    Axis[AXIS_INDEX].Status.ActVelocity := MC_ReadActualVelocity_0.Velocity;
END_IF


CASE AxisStep OF
(****************************** WAIT ********************************)
    STATE_WAIT: (* STATE: Wait *)
        IF ((GlobalCommand.Power = TRUE) OR (Axis[AXIS_INDEX].Command.Power = TRUE)) THEN
            AxisStep := STATE_POWER_ON;
        ELSE
            MC_Power_0.Enable := FALSE;
        END_IF

        (* reset all FB execute inputs we use *)
        MC_Home_0.Execute := FALSE;
        MC_Halt_0.Execute := FALSE;
        MC_Stop_0.Execute := FALSE;
        MC_MoveAbsolute_0.Execute := FALSE;
        MC_MoveAdditive_0.Execute := FALSE;
        MC_MoveVelocity_0.Execute := FALSE;

        (* reset user commands *)
        Axis[AXIS_INDEX].Command.Stop := FALSE;
        Axis[AXIS_INDEX].Command.MoveJogPos := FALSE;
        Axis[AXIS_INDEX].Command.MoveJogNeg := FALSE;
        Axis[AXIS_INDEX].Command.MoveVelocity := FALSE;
        Axis[AXIS_INDEX].Command.MoveAbsolute := FALSE;
        Axis[AXIS_INDEX].Command.MoveAdditive := FALSE;

    (* End of STATE_WAIT *)

(****************************** POWER ON ****************************)
    STATE_POWER_ON: (* STATE: Power on *)
        IF (PowerSupplyOn = TRUE) THEN
            MC_Power_0.Enable := TRUE;
        END_IF
        IF (MC_Power_0.Status = TRUE) THEN
            AxisStep := STATE_READY;
        END_IF

        (* if a power error occured switch off controller *)
        IF (MC_Power_0.Error = TRUE) THEN
            MC_Power_0.Enable := FALSE;
        END_IF  

        (* End of STATE_POWER_ON *)

(****************************** READY *******************************)
    STATE_READY: (* STATE: Waiting for Commands *)
        IF ((Axis[AXIS_INDEX].Command.Home = TRUE) OR (GlobalCommand.Home = TRUE)) THEN
            Axis[AXIS_INDEX].Command.Home := FALSE;
            AxisStep := STATE_HOME;
        ELSIF ((Axis[AXIS_INDEX].Command.Stop = TRUE) OR (GlobalCommand.Stop = TRUE)) THEN
            AxisStep := STATE_STOP;
        ELSIF (Axis[AXIS_INDEX].Command.MoveJogPos = TRUE) THEN
            AxisStep := STATE_JOG_POSITIVE;
        ELSIF (Axis[AXIS_INDEX].Command.MoveJogNeg = TRUE) THEN
            AxisStep := STATE_JOG_NEGATIVE;
        ELSIF (Axis[AXIS_INDEX].Command.MoveAbsolute = TRUE) THEN
            Axis[AXIS_INDEX].Command.MoveAbsolute := FALSE;
            AxisStep := STATE_MOVE_ABSOLUTE;
        ELSIF (Axis[AXIS_INDEX].Command.MoveAdditive = TRUE) THEN
            Axis[AXIS_INDEX].Command.MoveAdditive := FALSE; 
            AxisStep := STATE_MOVE_ADDITIVE;
        ELSIF (Axis[AXIS_INDEX].Command.MoveVelocity = TRUE) THEN
            Axis[AXIS_INDEX].Command.MoveVelocity := FALSE;
            AxisStep := STATE_MOVE_VELOCITY;
        ELSIF (Axis[AXIS_INDEX].Command.Halt = TRUE) THEN
            Axis[AXIS_INDEX].Command.Halt := FALSE;
            AxisStep := STATE_HALT;
        END_IF

        (* End of STATE_READY *)

(****************************** HOME ********************************)
    STATE_HOME: (* STATE: start homing process *)
        MC_Home_0.Position := Axis[AXIS_INDEX].Parameter.HomePosition;
        MC_Home_0.HomingMode := Axis[AXIS_INDEX].Parameter.HomeMode;
        MC_Home_0.Execute := TRUE;
        IF (MC_Home_0.Done = TRUE) THEN
            GlobalCommand.Home := FALSE;
            MC_Home_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        (* if a homing error occured go to ready state *)
        IF ((MC_Home_0.Error = TRUE) OR (MC_Home_0.CommandAborted = TRUE)) THEN
            MC_Home_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        (* End of STATE_HOME *)

(*************************** HALT MOVEMENT **************************)
    STATE_HALT: (* STATE: Stop the active movement *)
        MC_Halt_0.Deceleration := Axis[AXIS_INDEX].Parameter.Deceleration;
        MC_Halt_0.Execute := TRUE;
        IF (MC_Halt_0.Done = TRUE) THEN
            MC_Halt_0.Execute := FALSE;
            AxisStep := STATE_READY;
       END_IF

       (* check if error occured *)
       IF ((MC_Halt_0.Error = TRUE) OR (MC_Halt_0.CommandAborted = TRUE)) THEN
           MC_Halt_0.Execute := FALSE;
           AxisStep := STATE_READY;
       END_IF

       (* End of STATE_HALT *)

(*************************** STOP MOVEMENT **************************)   
    STATE_STOP: (* STATE: Stop movement as long as command is set *)
        MC_Stop_0.Deceleration := Axis[AXIS_INDEX].Parameter.Deceleration;
        MC_Stop_0.Execute := TRUE;

        (* if axis is stopped go to ready state *)
        IF ((MC_Stop_0.Done = TRUE) AND (Axis[AXIS_INDEX].Command.Stop = FALSE) AND (GlobalCommand.Stop = FALSE)) THEN
            MC_Stop_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        (* check if error occured *)
        IF (((MC_Stop_0.Error = TRUE) OR (MC_Stop_0.CommandAborted = TRUE)) AND
             (Axis[AXIS_INDEX].Command.Stop = FALSE) AND
             (GlobalCommand.Stop = FALSE)) THEN
            MC_Stop_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

       (* End of STATE_STOP *)

(******************* START JOG MOVEMENT POSITIVE ********************)
    STATE_JOG_POSITIVE: (* STATE: Start jog movement in positive direction *)
        MC_MoveVelocity_0.Velocity      := Axis[AXIS_INDEX].Parameter.JogVelocity;
        MC_MoveVelocity_0.Acceleration  := Axis[AXIS_INDEX].Parameter.Acceleration;
        MC_MoveVelocity_0.Deceleration  := Axis[AXIS_INDEX].Parameter.Deceleration;
        MC_MoveVelocity_0.Direction     := mcPOSITIVE_DIR;
        MC_MoveVelocity_0.Execute := 1;

        (* check if jog movement should be stopped *)
        IF (Axis[AXIS_INDEX].Command.MoveJogPos = FALSE) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            AxisStep := STATE_HALT;
        END_IF

        IF ((MC_MoveVelocity_0.Error = TRUE) OR (MC_MoveVelocity_0.CommandAborted = TRUE)) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        (* End of STATE_JOG_POSITIVE *)

(********************START JOG MOVEMENT NEGATIVE ********************)
    STATE_JOG_NEGATIVE: (* STATE: Start jog movement in negative direction *)
        MC_MoveVelocity_0.Velocity      := Axis[AXIS_INDEX].Parameter.JogVelocity;
        MC_MoveVelocity_0.Acceleration  := Axis[AXIS_INDEX].Parameter.Acceleration;
        MC_MoveVelocity_0.Deceleration  := Axis[AXIS_INDEX].Parameter.Deceleration;
        MC_MoveVelocity_0.Direction     := mcNEGATIVE_DIR;
        MC_MoveVelocity_0.Execute := 1;

        (* check if jog movement should be stopped *)
        IF (Axis[AXIS_INDEX].Command.MoveJogNeg = FALSE) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            AxisStep := STATE_HALT;
        END_IF

        IF ((MC_MoveVelocity_0.Error = TRUE) OR (MC_MoveVelocity_0.CommandAborted = TRUE)) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        (* End of STATE_JOG_NEGATIVE *)

(********************* START ABSOLUTE MOVEMENT **********************)
    STATE_MOVE_ABSOLUTE: (* STATE: Start absolute movement *)
        MC_MoveAbsolute_0.Position      := Axis[AXIS_INDEX].Parameter.Position;
        MC_MoveAbsolute_0.Velocity      := Axis[AXIS_INDEX].Parameter.Velocity;
        MC_MoveAbsolute_0.Acceleration  := Axis[AXIS_INDEX].Parameter.Acceleration;
        MC_MoveAbsolute_0.Deceleration  := Axis[AXIS_INDEX].Parameter.Deceleration;
        MC_MoveAbsolute_0.Direction     := Axis[AXIS_INDEX].Parameter.Direction;
        MC_MoveAbsolute_0.Execute := 1;

        IF (Axis[AXIS_INDEX].Command.Halt = TRUE) THEN
            Axis[AXIS_INDEX].Command.Halt := 0;
            MC_MoveAbsolute_0.Execute := 0;
            AxisStep := STATE_HALT;
        ELSIF (MC_MoveAbsolute_0.Done = TRUE) THEN
            MC_MoveAbsolute_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        IF ((MC_MoveAbsolute_0.Error = TRUE) OR (MC_MoveAbsolute_0.CommandAborted = TRUE)) THEN
            MC_MoveAbsolute_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        (* End of STATE_MOVE_ABSOLUTE *)

(********************* START ADDITIVE MOVEMENT **********************)
    STATE_MOVE_ADDITIVE: (* STATE: Start additive movement *)
        MC_MoveAdditive_0.Distance      := Axis[AXIS_INDEX].Parameter.Distance;
        MC_MoveAdditive_0.Velocity      := Axis[AXIS_INDEX].Parameter.Velocity;
        MC_MoveAdditive_0.Acceleration  := Axis[AXIS_INDEX].Parameter.Acceleration;
        MC_MoveAdditive_0.Deceleration  := Axis[AXIS_INDEX].Parameter.Deceleration;
        MC_MoveAdditive_0.Execute := 1;
        IF (Axis[AXIS_INDEX].Command.Halt = TRUE) THEN
            Axis[AXIS_INDEX].Command.Halt := FALSE;
            MC_MoveAdditive_0.Execute := FALSE;
            AxisStep := STATE_HALT;
        ELSIF (MC_MoveAdditive_0.Done = TRUE) THEN
            MC_MoveAdditive_0.Execute := FALSE;
             AxisStep := STATE_READY;
        END_IF

        (* check IF error occured *)
        IF ((MC_MoveAdditive_0.Error = TRUE) OR (MC_MoveAdditive_0.CommandAborted = TRUE)) THEN
            MC_MoveAdditive_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        (* End of STATE_MOVE_ADDITIVE *)

(********************* START VELOCITY MOVEMENT **********************)
    STATE_MOVE_VELOCITY: (* STATE: Start velocity movement *)
        MC_MoveVelocity_0.Velocity      := Axis[AXIS_INDEX].Parameter.Velocity;
        MC_MoveVelocity_0.Acceleration  := Axis[AXIS_INDEX].Parameter.Acceleration;
        MC_MoveVelocity_0.Deceleration  := Axis[AXIS_INDEX].Parameter.Deceleration;
        MC_MoveVelocity_0.Direction     := Axis[AXIS_INDEX].Parameter.Direction;
        MC_MoveVelocity_0.Execute := 1;

        IF (Axis[AXIS_INDEX].Command.Halt = TRUE) THEN
            Axis[AXIS_INDEX].Command.Halt := FALSE;
            MC_MoveVelocity_0.Execute := FALSE;
            AxisStep := STATE_HALT;
        ELSIF (MC_MoveVelocity_0.InVelocity = TRUE) THEN
            MC_MoveVelocity_0.Execute := FALSE;
             AxisStep := STATE_READY;
        END_IF
        (* check if error occured *)
        IF ((MC_MoveVelocity_0.Error = TRUE) OR (MC_MoveVelocity_0.CommandAborted = TRUE)) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            AxisStep := STATE_READY;
        END_IF

        (* End of STATE_MOVE_ADDITIVE *)

(*********************** SEQUENCE END *******************************)
END_CASE

(*********************************************************************
        Function Block Calls
*********************************************************************)

(*************************** MC_POWER *******************************)
MC_Power_0.Axis := AxisRef[AXIS_INDEX];
MC_Power_0();

(**************************** MC_HOME *******************************)
MC_Home_0.Axis := AxisRef[AXIS_INDEX];
MC_Home_0();

(************************ MC_MOVEABSOLUTE ***************************)
MC_MoveAbsolute_0.Axis := AxisRef[AXIS_INDEX];
MC_MoveAbsolute_0();

(************************ MC_MOVEADDITIVE ***************************)
MC_MoveAdditive_0.Axis := AxisRef[AXIS_INDEX];
MC_MoveAdditive_0();

(************************ MC_MOVEVELOCITY ***************************)
MC_MoveVelocity_0.Axis := AxisRef[AXIS_INDEX];
MC_MoveVelocity_0();

(**************************** MC_STOP *******************************)
MC_Stop_0.Axis := AxisRef[AXIS_INDEX];
MC_Stop_0();

(****************************MC_HALT*********************************)
MC_Halt_0.Axis := AxisRef[AXIS_INDEX];
MC_Halt_0();

END_PROGRAM
