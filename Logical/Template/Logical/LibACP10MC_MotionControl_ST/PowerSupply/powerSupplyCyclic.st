(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: PowerSupply
 * File: powerSupplyCyclic.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program PowerSupply
 ********************************************************************)

PROGRAM _CYCLIC

(************************** MC_READSTATUS ***************************)
MC_ReadStatus_0.Enable := NOT(MC_ReadStatus_0.Error);
MC_ReadStatus_0.Axis := PsmRef[PSM_INDEX];
MC_ReadStatus_0();
PowerSupply[PSM_INDEX].AxisState.Disabled := MC_ReadStatus_0.Disabled;
PowerSupply[PSM_INDEX].AxisState.StandStill := MC_ReadStatus_0.StandStill;
PowerSupply[PSM_INDEX].AxisState.Stopping := MC_ReadStatus_0.Stopping;
PowerSupply[PSM_INDEX].AxisState.Homing := MC_ReadStatus_0.Homing;
PowerSupply[PSM_INDEX].AxisState.DiscreteMotion := MC_ReadStatus_0.DiscreteMotion;
PowerSupply[PSM_INDEX].AxisState.ContinuousMotion := MC_ReadStatus_0.ContinuousMotion;
PowerSupply[PSM_INDEX].AxisState.SynchronizedMotion := MC_ReadStatus_0.SynchronizedMotion;
PowerSupply[PSM_INDEX].AxisState.ErrorStop := MC_ReadStatus_0.Errorstop;

(************************* MC_BR_READDRIVESTATUS ********************)
MC_BR_ReadDriveStatus_0.Enable := NOT(MC_BR_ReadDriveStatus_0.Error);
MC_BR_ReadDriveStatus_0.Axis := PsmRef[PSM_INDEX];
MC_BR_ReadDriveStatus_0.AdrDriveStatus := ADR(PowerSupply[PSM_INDEX].Status.DriveStatus);
MC_BR_ReadDriveStatus_0();

CASE PsmStep OF
(********************************* READY ****************************)
    STATE_READY:
        IF (((GlobalCommand.Power = TRUE) OR (PowerSupply[PSM_INDEX].Command.Power = TRUE)) AND
             (MC_Power_0.Status = FALSE)) THEN
            PsmStep := STATE_POWER_ON;
        ELSIF ((GlobalCommand.Power = FALSE) AND (PowerSupply[PSM_INDEX].Command.Power = FALSE) AND
                 (MC_Power_0.Status = TRUE)) THEN
            PsmStep := STATE_POWER_OFF;
        ELSIF (PowerSupply[PSM_INDEX].Command.StartPowerMeter = TRUE) THEN
            PowerSupply[PSM_INDEX].Command.StartPowerMeter := FALSE;
            PsmStep := STATE_START_POWERMETER;
        ELSIF (PowerSupply[PSM_INDEX].Command.StopPowerMeter = TRUE) THEN
            PowerSupply[PSM_INDEX].Command.StopPowerMeter := FALSE;
            PsmStep := STATE_STOP_POWERMETER;
        ELSIF (PowerSupply[PSM_INDEX].Command.RestartInterval = TRUE) THEN
            PowerSupply[PSM_INDEX].Command.RestartInterval := FALSE;
            MC_BR_PowerMeter_0.RestartInterval := FALSE;
            PsmStep := STATE_RESTART_INTERVAL;
        END_IF

        (* End of STATE_READY *)

(*************************** POWER ON ********************************)
    STATE_POWER_ON:
        MC_Power_0.Enable := TRUE;
        IF (MC_Power_0.Status = TRUE) THEN
            PsmStep := STATE_READY;
        END_IF

        (* IF a power error occured switch off controller *)
        IF (MC_Power_0.Error = TRUE) THEN
            MC_Power_0.Enable := FALSE;
        END_IF

        (* End of STATE_POWER_ON *)

(************************* POWER OFF *******************************)
    STATE_POWER_OFF:
        MC_Power_0.Enable := FALSE;
        IF (MC_Power_0.Status = FALSE) THEN
            PsmStep := STATE_READY;
        END_IF

        (* End of STATE_POWER_OFF *)

(************************ START POWERMETER **************************)
    STATE_START_POWERMETER:
        MC_BR_PowerMeter_0.Enable := TRUE;
        MC_BR_PowerMeter_0.Mode := mcONLY_PSM;
        MC_BR_PowerMeter_0.IntervalTime := PowerSupply[PSM_INDEX].Parameter.IntervalTime;

        IF (MC_BR_PowerMeter_0.Valid = TRUE) THEN
            PsmStep := STATE_READY;   
        END_IF

        (* check IF error occured *)
        IF (MC_BR_PowerMeter_0.Error = TRUE) THEN
            MC_BR_PowerMeter_0.Enable := FALSE;
            PsmStep := STATE_READY;   
        END_IF

        (* End of STATE_START_POWERMETER *)

(************************ STOP POWERMETER ***************************)
    STATE_STOP_POWERMETER:
        MC_BR_PowerMeter_0.Enable := FALSE;

        IF (MC_BR_PowerMeter_0.Valid = FALSE) THEN
            PsmStep := STATE_READY;   
        END_IF

        (* End of STATE_STOP_POWERMETER *)

(********************** STATE RESTART INTERVAL **********************)
    STATE_RESTART_INTERVAL:
        MC_BR_PowerMeter_0.RestartInterval := TRUE;
        PsmStep := STATE_READY;

        (* End of STATE_RESTART_INTERVAL *)

(*********************** SEQUENCE END *******************************)
END_CASE

(*********************************************************************
        Function Block Calls
*********************************************************************)

(*************************** MC_POWER *******************************)
MC_Power_0.Axis := PsmRef[PSM_INDEX];
MC_Power_0();
PowerSupplyOn := MC_Power_0.Status;

(**********************MC_BR_POWERMETER *****************************)
MC_BR_PowerMeter_0.Axis := PsmRef[PSM_INDEX];
MC_BR_PowerMeter_0();
PowerSupply[PSM_INDEX].Status.PowerData.IntervalNumber        := MC_BR_PowerMeter_0.PowerData.IntervalNumber;
PowerSupply[PSM_INDEX].Status.PowerData.IntervalDuration      := MC_BR_PowerMeter_0.PowerData.IntervalDuration;
PowerSupply[PSM_INDEX].Status.PowerData.AverageActivePower    := MC_BR_PowerMeter_0.PowerData.AverageActivePower;
PowerSupply[PSM_INDEX].Status.PowerData.AverageReactivePower  := MC_BR_PowerMeter_0.PowerData.AverageReactivePower;
PowerSupply[PSM_INDEX].Status.PowerData.MaximumActivePower    := MC_BR_PowerMeter_0.PowerData.MaximumActivePower;
PowerSupply[PSM_INDEX].Status.PowerData.MinimalActivePower    := MC_BR_PowerMeter_0.PowerData.MinimalActivePower;
PowerSupply[PSM_INDEX].Status.PowerData.ConsumedEnergy        := MC_BR_PowerMeter_0.PowerData.ConsumedEnergy;
PowerSupply[PSM_INDEX].Status.PowerData.RegeneratedEnergy     := MC_BR_PowerMeter_0.PowerData.RegeneratedEnergy;
PowerSupply[PSM_INDEX].Status.PowerData.EnergyBalance         := MC_BR_PowerMeter_0.PowerData.EnergyBalance;

END_PROGRAM
