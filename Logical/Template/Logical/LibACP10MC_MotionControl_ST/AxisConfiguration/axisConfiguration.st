(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: AxisConfiguration
 * File: axisConfiguration.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program AxisConfiguration
 ********************************************************************)

PROGRAM _INIT
    PsmRef[0] := ADR(gAxis01); (* axis reference of the power supply module *)
    AxisRef[0] := ADR(gAxis02); (* axis reference of first single axis *)
    AxisRef[1] := ADR(gAxis03); (* axis reference of second single axis *)
    MasterRef[0] := ADR(gAxis04); (* axis reference of first master axis *)
    SlaveRef[0] := ADR(gAxis05); (* axis reference of first slave axis *)

    PowerSupplyOn := TRUE; (* if a power supply is used, this variable is reset in the according task *)
END_PROGRAM


