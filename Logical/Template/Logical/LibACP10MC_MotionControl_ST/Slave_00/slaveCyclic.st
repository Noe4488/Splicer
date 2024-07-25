(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: Slave_00
 * File: slaveCyclic.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program Slave_00
 ********************************************************************)

PROGRAM _CYCLIC

(************CHECK IF POWER SHOULD BE OFF ***************************)
    IF ((GlobalCommand.Power = FALSE) AND (Slave[SLAVE_INDEX].Command.Power = FALSE)) THEN
        SlaveStep := STATE_WAIT;
    END_IF

    (* central monitoring of the stop command allows a shorter reaction time *)
    IF ((GlobalCommand.Stop = TRUE) OR (Slave[SLAVE_INDEX].Command.Stop = TRUE)) THEN
        IF ((GlobalCommand.Power = TRUE) OR (Slave[SLAVE_INDEX].Command.Power = TRUE)) THEN
            SlaveStep := STATE_STOP;
            (* reset all FB execute inputs we use *)
            MC_Home_0.Execute := FALSE;
            MC_Halt_0.Execute := FALSE;
            MC_MoveAbsolute_0.Execute := FALSE;
            MC_MoveAdditive_0.Execute := FALSE;
            MC_MoveVelocity_0.Execute := FALSE;

            MC_BR_InitAutData_0.Execute := FALSE;
            MC_BR_AutCommand_0.Enable := FALSE;
            MC_BR_AutCommand_0.Start := FALSE;
            MC_BR_AutCommand_0.Restart := FALSE;
            MC_BR_AutCommand_0.Stop := FALSE;
            MC_BR_AutCommand_0.EndAutomat := FALSE;

            Slave[SLAVE_INDEX].Command.MoveJogPos := FALSE;
            Slave[SLAVE_INDEX].Command.MoveJogNeg := FALSE;
        END_IF
    END_IF

(************************** MC_READSTATUS ***************************)
MC_ReadStatus_0.Enable := NOT(MC_ReadStatus_0.Error);
MC_ReadStatus_0.Axis := SlaveRef[SLAVE_INDEX];
MC_ReadStatus_0();
Slave[SLAVE_INDEX].AxisState.Disabled             := MC_ReadStatus_0.Disabled;
Slave[SLAVE_INDEX].AxisState.StandStill           := MC_ReadStatus_0.StandStill;
Slave[SLAVE_INDEX].AxisState.Stopping             := MC_ReadStatus_0.Stopping;
Slave[SLAVE_INDEX].AxisState.Homing               := MC_ReadStatus_0.Homing;
Slave[SLAVE_INDEX].AxisState.DiscreteMotion       := MC_ReadStatus_0.DiscreteMotion;
Slave[SLAVE_INDEX].AxisState.ContinuousMotion     := MC_ReadStatus_0.ContinuousMotion;
Slave[SLAVE_INDEX].AxisState.SynchronizedMotion   := MC_ReadStatus_0.SynchronizedMotion;
Slave[SLAVE_INDEX].AxisState.ErrorStop            := MC_ReadStatus_0.Errorstop;

(********************** MC_BR_READDRIVESTATUS ***********************)
MC_BR_ReadDriveStatus_0.Enable := NOT(MC_BR_ReadDriveStatus_0.Error);
MC_BR_ReadDriveStatus_0.Axis := SlaveRef[SLAVE_INDEX];
MC_BR_ReadDriveStatus_0.AdrDriveStatus := ADR(Slave[SLAVE_INDEX].Status.DriveStatus);
MC_BR_ReadDriveStatus_0();

(********************* MC_READACTUALPOSITION ************************)
MC_ReadActualPosition_0.Enable := NOT(MC_ReadActualPosition_0.Error);
MC_ReadActualPosition_0.Axis := SlaveRef[SLAVE_INDEX];
MC_ReadActualPosition_0();
IF(MC_ReadActualPosition_0.Valid = TRUE) THEN
    Slave[SLAVE_INDEX].Status.ActPosition := MC_ReadActualPosition_0.Position;
END_IF

(********************* MC_READACTUALVELOCITY ************************)
MC_ReadActualVelocity_0.Enable := NOT(MC_ReadActualVelocity_0.Error);
MC_ReadActualVelocity_0.Axis := SlaveRef[SLAVE_INDEX];
MC_ReadActualVelocity_0();
IF(MC_ReadActualVelocity_0.Valid = TRUE) THEN
    Slave[SLAVE_INDEX].Status.ActVelocity := MC_ReadActualVelocity_0.Velocity;
END_IF


CASE SlaveStep OF
(****************************** WAIT ********************************)
    STATE_WAIT: (* STATE: Wait *)
        IF ((GlobalCommand.Power = TRUE) OR (Slave[SLAVE_INDEX].Command.Power = TRUE)) THEN
            SlaveStep := STATE_POWER_ON;
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
        Slave[SLAVE_INDEX].Command.Stop := FALSE;
        Slave[SLAVE_INDEX].Command.MoveJogPos := FALSE;
        Slave[SLAVE_INDEX].Command.MoveJogNeg := FALSE;
        Slave[SLAVE_INDEX].Command.MoveVelocity := FALSE;
        Slave[SLAVE_INDEX].Command.MoveAbsolute := FALSE;
        Slave[SLAVE_INDEX].Command.MoveAdditive := FALSE;

    (* End of STATE_WAIT *)

(****************************** POWER ON ****************************)
    STATE_POWER_ON: (* STATE: Power on *)
        IF (PowerSupplyOn = TRUE) THEN
            MC_Power_0.Enable := TRUE;
        END_IF
        IF (MC_Power_0.Status = TRUE) THEN
            SlaveStep := STATE_READY;
        END_IF

        (* if a power error occured switch off controller *)
        IF (MC_Power_0.Error = TRUE) THEN
            MC_Power_0.Enable := FALSE;
        END_IF

        (* End of STATE_POWER_ON *)

(****************************** READY *******************************)
    STATE_READY: (* STATE: Waiting for Commands *)
        IF ((Slave[SLAVE_INDEX].Command.Home = TRUE) OR (GlobalCommand.Home = TRUE)) THEN
            Slave[SLAVE_INDEX].Command.Home := FALSE;
            SlaveStep := STATE_HOME;
        ELSIF ((Slave[SLAVE_INDEX].Command.Stop = TRUE) OR (GlobalCommand.Stop = TRUE)) THEN
            SlaveStep := STATE_STOP;
        ELSIF (Slave[SLAVE_INDEX].Command.MoveJogPos = TRUE) THEN
            SlaveStep := STATE_JOG_POSITIVE;
        ELSIF (Slave[SLAVE_INDEX].Command.MoveJogNeg = TRUE) THEN
            SlaveStep := STATE_JOG_NEGATIVE;
        ELSIF (Slave[SLAVE_INDEX].Command.MoveAbsolute = TRUE) THEN
            Slave[SLAVE_INDEX].Command.MoveAbsolute := FALSE;
            SlaveStep := STATE_MOVE_ABSOLUTE;
        ELSIF (Slave[SLAVE_INDEX].Command.MoveAdditive = TRUE) THEN
            Slave[SLAVE_INDEX].Command.MoveAdditive := FALSE; 
            SlaveStep := STATE_MOVE_ADDITIVE;
        ELSIF (Slave[SLAVE_INDEX].Command.MoveVelocity = TRUE) THEN
            Slave[SLAVE_INDEX].Command.MoveVelocity := FALSE;
            SlaveStep := STATE_MOVE_VELOCITY;
        ELSIF (Slave[SLAVE_INDEX].Command.Halt = TRUE) THEN
            Slave[SLAVE_INDEX].Command.Halt := FALSE;
            SlaveStep := STATE_HALT;
        ELSIF (Slave[SLAVE_INDEX].Command.StartAutomat = TRUE) THEN
            Slave[SLAVE_INDEX].Command.StartAutomat := FALSE;
            SlaveStep := STATE_AUTOMAT_INIT;
        ELSIF (Slave[SLAVE_INDEX].Command.RestartAutomat = TRUE) THEN
            Slave[SLAVE_INDEX].Command.RestartAutomat := FALSE;
            SlaveStep := STATE_AUTOMAT_RESTART;
        ELSIF (Slave[SLAVE_INDEX].Command.EndAutomat = TRUE) THEN
            Slave[SLAVE_INDEX].Command.EndAutomat := FALSE;
            SlaveStep := STATE_AUTOMAT_END;
        ELSIF (Slave[SLAVE_INDEX].Command.StopSlave = TRUE) THEN
            Slave[SLAVE_INDEX].Command.StopSlave := FALSE;
            SlaveStep := STATE_AUTOMAT_STOP;
        END_IF

        (* End of STATE_READY *)

(****************************** HOME ********************************)
    STATE_HOME: (* STATE: start homing process *)
        MC_Home_0.Position := Slave[SLAVE_INDEX].Parameter.HomePosition;
        MC_Home_0.HomingMode := Slave[SLAVE_INDEX].Parameter.HomeMode;
        MC_Home_0.Execute := TRUE;
        IF (MC_Home_0.Done = TRUE) THEN
            GlobalCommand.Home := FALSE;
            MC_Home_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* if a homing error occured go to ready state *)
        IF ((MC_Home_0.Error = TRUE) OR (MC_Home_0.CommandAborted = TRUE)) THEN
            MC_Home_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_HOME *)

(*************************** HALT MOVEMENT **************************)
    STATE_HALT: (* STATE: Stop the active movement *)
        MC_Halt_0.Deceleration := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_Halt_0.Execute := TRUE;
        IF (MC_Halt_0.Done = TRUE) THEN
            MC_Halt_0.Execute := FALSE;
            SlaveStep := STATE_READY;
       END_IF

       (* check if error occured *)
       IF ((MC_Halt_0.Error = TRUE) OR (MC_Halt_0.CommandAborted = TRUE)) THEN
           MC_Halt_0.Execute := FALSE;
           SlaveStep := STATE_READY;
       END_IF

       (* End of STATE_HALT *)

(*************************** STOP MOVEMENT **************************)
    STATE_STOP: (* STATE: Stop movement as long as command is set *)
        MC_Stop_0.Deceleration := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_Stop_0.Execute := TRUE;

        (* if axis is stopped go to ready state *)
        IF ((MC_Stop_0.Done = TRUE) AND (Slave[SLAVE_INDEX].Command.Stop = FALSE) AND (GlobalCommand.Stop = FALSE)) THEN
            MC_Stop_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* check if error occured *)
        IF (((MC_Stop_0.Error = TRUE) OR (MC_Stop_0.CommandAborted = TRUE)) AND
             (Slave[SLAVE_INDEX].Command.Stop = FALSE) AND
             (GlobalCommand.Stop = FALSE)) THEN
            MC_Stop_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

       (* End of STATE_STOP *)

(******************* START JOG MOVEMENT POSITIVE ********************)
    STATE_JOG_POSITIVE: (* STATE: Start jog movement in positive direction *)
        MC_MoveVelocity_0.Velocity      := Slave[SLAVE_INDEX].Parameter.JogVelocity;
        MC_MoveVelocity_0.Acceleration  := Slave[SLAVE_INDEX].Parameter.Acceleration;
        MC_MoveVelocity_0.Deceleration  := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_MoveVelocity_0.Direction     := mcPOSITIVE_DIR;
        MC_MoveVelocity_0.Execute := 1;

        (* check if jog movement should be stopped *)
        IF (Slave[SLAVE_INDEX].Command.MoveJogPos = FALSE) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            SlaveStep := STATE_HALT;
        END_IF

        IF ((MC_MoveVelocity_0.Error = TRUE) OR (MC_MoveVelocity_0.CommandAborted = TRUE)) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_JOG_POSITIVE *)

(********************START JOG MOVEMENT NEGATIVE ********************)
    STATE_JOG_NEGATIVE: (* STATE: Start jog movement in negative direction *)
        MC_MoveVelocity_0.Velocity      := Slave[SLAVE_INDEX].Parameter.JogVelocity;
        MC_MoveVelocity_0.Acceleration  := Slave[SLAVE_INDEX].Parameter.Acceleration;
        MC_MoveVelocity_0.Deceleration  := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_MoveVelocity_0.Direction     := mcNEGATIVE_DIR;
        MC_MoveVelocity_0.Execute := 1;

        (* check if jog movement should be stopped *)
        IF (Slave[SLAVE_INDEX].Command.MoveJogNeg = FALSE) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            SlaveStep := STATE_HALT;
        END_IF

        IF ((MC_MoveVelocity_0.Error = TRUE) OR (MC_MoveVelocity_0.CommandAborted = TRUE)) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_JOG_NEGATIVE *)

(********************* START ABSOLUTE MOVEMENT **********************)
    STATE_MOVE_ABSOLUTE: (* STATE: Start absolute movement *)
        MC_MoveAbsolute_0.Position      := Slave[SLAVE_INDEX].Parameter.Position;
        MC_MoveAbsolute_0.Velocity      := Slave[SLAVE_INDEX].Parameter.Velocity;
        MC_MoveAbsolute_0.Acceleration  := Slave[SLAVE_INDEX].Parameter.Acceleration;
        MC_MoveAbsolute_0.Deceleration  := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_MoveAbsolute_0.Direction     := Slave[SLAVE_INDEX].Parameter.Direction;
        MC_MoveAbsolute_0.Execute := 1;

        IF (Slave[SLAVE_INDEX].Command.Halt = TRUE) THEN
            Slave[SLAVE_INDEX].Command.Halt := 0;
            MC_MoveAbsolute_0.Execute := 0;
            SlaveStep := STATE_HALT;
        ELSIF (MC_MoveAbsolute_0.Done = TRUE) THEN
            MC_MoveAbsolute_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        IF ((MC_MoveAbsolute_0.Error = TRUE) OR (MC_MoveAbsolute_0.CommandAborted = TRUE)) THEN
            MC_MoveAbsolute_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_MOVE_ABSOLUTE *)

(********************* START ADDITIVE MOVEMENT **********************)
    STATE_MOVE_ADDITIVE: (* STATE: Start additive movement *)
        MC_MoveAdditive_0.Distance      := Slave[SLAVE_INDEX].Parameter.Distance;
        MC_MoveAdditive_0.Velocity      := Slave[SLAVE_INDEX].Parameter.Velocity;
        MC_MoveAdditive_0.Acceleration  := Slave[SLAVE_INDEX].Parameter.Acceleration;
        MC_MoveAdditive_0.Deceleration  := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_MoveAdditive_0.Execute := 1;
        IF (Slave[SLAVE_INDEX].Command.Halt = TRUE) THEN
            Slave[SLAVE_INDEX].Command.Halt := FALSE;
            MC_MoveAdditive_0.Execute := FALSE;
            SlaveStep := STATE_HALT;
        ELSIF (MC_MoveAdditive_0.Done = TRUE) THEN
            MC_MoveAdditive_0.Execute := FALSE;
             SlaveStep := STATE_READY;
        END_IF

        (* check IF error occured *)
        IF ((MC_MoveAdditive_0.Error = TRUE) OR (MC_MoveAdditive_0.CommandAborted = TRUE)) THEN
            MC_MoveAdditive_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_MOVE_ADDITIVE *)

(********************* START VELOCITY MOVEMENT **********************)
    STATE_MOVE_VELOCITY: (* STATE: Start velocity movement *)
        MC_MoveVelocity_0.Velocity      := Slave[SLAVE_INDEX].Parameter.Velocity;
        MC_MoveVelocity_0.Acceleration  := Slave[SLAVE_INDEX].Parameter.Acceleration;
        MC_MoveVelocity_0.Deceleration  := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_MoveVelocity_0.Direction     := Slave[SLAVE_INDEX].Parameter.Direction;
        MC_MoveVelocity_0.Execute := 1;

        IF (Slave[SLAVE_INDEX].Command.Halt = TRUE) THEN
            Slave[SLAVE_INDEX].Command.Halt := FALSE;
            MC_MoveVelocity_0.Execute := FALSE;
            SlaveStep := STATE_HALT;
        ELSIF (MC_MoveVelocity_0.InVelocity = TRUE) THEN
            MC_MoveVelocity_0.Execute := FALSE;
             SlaveStep := STATE_READY;
        END_IF
        (* check if error occured *)
        IF ((MC_MoveVelocity_0.Error = TRUE) OR (MC_MoveVelocity_0.CommandAborted = TRUE)) THEN
            MC_MoveVelocity_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_MOVE_ADDITIVE *)

(****************** INITIALIZE AUTOMAT PARAMETERS *******************)
    STATE_AUTOMAT_INIT:
        Labeler(MasterRef[0],AutData); (*Call of the function with the Automat Data*)

        MC_BR_InitAutData_0.InitOptions.GlobalParams      := mcALL_PARAMS;
        MC_BR_InitAutData_0.InitOptions.StateIndex        := mcALL_STATES;
        MC_BR_InitAutData_0.InitOptions.EventIndex        := mcALL_EVENTS;
        MC_BR_InitAutData_0.InitOptions.MaxStatesPerCycle := 14;
        MC_BR_InitAutData_0.InitOptions.Force             := mcOFF;
        MC_BR_InitAutData_0.AdrAutData  := ADR(AutData);
        MC_BR_InitAutData_0.Execute     := TRUE;

        (* wait for initialization done *)
        IF (MC_BR_InitAutData_0.Done = TRUE) THEN
            MC_BR_InitAutData_0.Execute := FALSE;
            SlaveStep := STATE_AUTOMAT_START;
        END_IF

        (* check if error occured *)
        IF (MC_BR_InitAutData_0.Error = TRUE) THEN
            MC_BR_InitAutData_0.Execute := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_MOVE_VELOCITY *)

(********************** ENABLE CAM-AUTOMAT **************************)
    STATE_AUTOMAT_START:
        MC_BR_AutCommand_0.Enable := TRUE;
        MC_BR_AutCommand_0.Start := TRUE;

        (* wait for autoamt stop *)
        IF (Slave[SLAVE_INDEX].Command.Halt = TRUE) THEN
            Slave[SLAVE_INDEX].Command.Halt := FALSE;
            MC_BR_AutCommand_0.Enable := FALSE;
            MC_BR_AutCommand_0.Start := FALSE;
            SlaveStep := STATE_HALT;
        ELSIF (MC_BR_AutCommand_0.Running = TRUE) THEN          
            MC_BR_AutCommand_0.Start := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* check if error occured *)
        IF (MC_BR_AutCommand_0.Error = TRUE) THEN
            MC_BR_AutCommand_0.Enable := FALSE;
            MC_BR_AutCommand_0.Start := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_AUTOMAT_START *)

(********************** RESTART CAM-AUTOMAT *************************)
    STATE_AUTOMAT_RESTART:
        IF (MC_BR_AutCommand_0.StandBy = FALSE) THEN
            SlaveStep := STATE_READY;
            RETURN;
        END_IF

        MC_BR_AutCommand_0.Enable := TRUE;
        MC_BR_AutCommand_0.Restart := TRUE;

        (* wait for autoamt stop *)
        IF (Slave[SLAVE_INDEX].Command.Halt = TRUE) THEN
            Slave[SLAVE_INDEX].Command.Halt := FALSE;
            MC_BR_AutCommand_0.Enable := FALSE;
            MC_BR_AutCommand_0.Restart := FALSE;
            SlaveStep := STATE_HALT;
        ELSIF (MC_BR_AutCommand_0.Running = TRUE) THEN
            MC_BR_AutCommand_0.Restart := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* check if error occured *)
        IF (MC_BR_AutCommand_0.Error = TRUE) THEN
            MC_BR_AutCommand_0.Enable := FALSE;
            MC_BR_AutCommand_0.Restart := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_AUTOMAT_RESTART *)

(*********************** STOP CAM-AUTOMAT ***************************)
    STATE_AUTOMAT_STOP:
        MC_BR_AutCommand_0.Deceleration := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_BR_AutCommand_0.Stop := TRUE;

        (* check if automat is stopped *)
        IF (MC_BR_AutCommand_0.Running = FALSE) THEN
            MC_BR_AutCommand_0.Stop := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        IF (MC_BR_AutCommand_0.Error = TRUE) THEN
            MC_BR_AutCommand_0.Enable := FALSE;
            MC_BR_AutCommand_0.Stop := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_AUTOMAT_STOP *)

(************************ END CAM-AUTOMAT ***************************)
    STATE_AUTOMAT_END:
        MC_BR_AutCommand_0.Deceleration := Slave[SLAVE_INDEX].Parameter.Deceleration;
        MC_BR_AutCommand_0.Stop := TRUE;

        (* check if automat is stopped *)
        IF (MC_BR_AutCommand_0.Running = FALSE) THEN
            MC_BR_AutCommand_0.Enable := FALSE;
            MC_BR_AutCommand_0.EndAutomat := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* check if error occured *)
        IF (MC_BR_AutCommand_0.Error = TRUE) THEN
            MC_BR_AutCommand_0.Enable := FALSE;
            MC_BR_AutCommand_0.EndAutomat := FALSE;
            SlaveStep := STATE_READY;
        END_IF

        (* End of STATE_AUTOMAT_STOP *)

(*********************** SEQUENCE END *******************************)
END_CASE

(*********************************************************************
        Function Block Calls
*********************************************************************)

(*************************** MC_POWER *******************************)
MC_Power_0.Axis := SlaveRef[SLAVE_INDEX];
MC_Power_0();

(**************************** MC_HOME *******************************)
MC_Home_0.Axis := SlaveRef[SLAVE_INDEX];
MC_Home_0();

(************************ MC_MOVEABSOLUTE ***************************)
MC_MoveAbsolute_0.Axis := SlaveRef[SLAVE_INDEX];
MC_MoveAbsolute_0();

(************************ MC_MOVEADDITIVE ***************************)
MC_MoveAdditive_0.Axis := SlaveRef[SLAVE_INDEX];
MC_MoveAdditive_0();

(************************ MC_MOVEVELOCITY ***************************)
MC_MoveVelocity_0.Axis := SlaveRef[SLAVE_INDEX];
MC_MoveVelocity_0();

(**************************** MC_STOP *******************************)
MC_Stop_0.Axis := SlaveRef[SLAVE_INDEX];
MC_Stop_0();

(*************************** MC_HALT ********************************)
MC_Halt_0.Axis := SlaveRef[SLAVE_INDEX];
MC_Halt_0();

(********************** MC_BR_INITAUTDATA ***************************)
MC_BR_InitAutData_0.Slave := SlaveRef[SLAVE_INDEX];
MC_BR_InitAutData_0();

(*********************** MC_BR_AUTCOMMAND ***************************)
MC_BR_AutCommand_0.SetSignal1 := Slave[SLAVE_INDEX].Command.SetSignal1;
MC_BR_AutCommand_0.SetSignal2 := Slave[SLAVE_INDEX].Command.SetSignal2;
MC_BR_AutCommand_0.SetSignal3 := Slave[SLAVE_INDEX].Command.SetSignal3;
MC_BR_AutCommand_0.SetSignal4 := Slave[SLAVE_INDEX].Command.SetSignal4;
MC_BR_AutCommand_0.ResetSignal1 := Slave[SLAVE_INDEX].Command.ResetSignal1;
MC_BR_AutCommand_0.ResetSignal2 := Slave[SLAVE_INDEX].Command.ResetSignal2;
MC_BR_AutCommand_0.ResetSignal3 := Slave[SLAVE_INDEX].Command.ResetSignal3;
MC_BR_AutCommand_0.ResetSignal4 := Slave[SLAVE_INDEX].Command.ResetSignal4;
MC_BR_AutCommand_0.Slave := SlaveRef[SLAVE_INDEX];
MC_BR_AutCommand_0();
Slave[SLAVE_INDEX].Status.AutomatRunning := MC_BR_AutCommand_0.Running;
Slave[SLAVE_INDEX].Status.AutomatStandBy := MC_BR_AutCommand_0.StandBy;
Slave[SLAVE_INDEX].Status.ActualStateIndex := MC_BR_AutCommand_0.ActualStateIndex;
Slave[SLAVE_INDEX].Status.ActualStateCamIndex := MC_BR_AutCommand_0.ActualStateCamIndex;
Slave[SLAVE_INDEX].Status.InCam := MC_BR_AutCommand_0.InCam;
Slave[SLAVE_INDEX].Status.InCompensation := MC_BR_AutCommand_0.InCompensation;
END_PROGRAM