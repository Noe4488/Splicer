(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: PowerSupply
 * File: powerSupplyInit.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program PowerSupply
 ********************************************************************)

PROGRAM _INIT
PsmStep := STATE_READY;

PowerSupply[PSM_INDEX].Parameter.IntervalTime := 10000; (* IntervalTime of 10sec *)
END_PROGRAM

