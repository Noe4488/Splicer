(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: Master_00
 * File: masterInit.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program Master_00
 ********************************************************************)

PROGRAM _INIT
MasterStep := STATE_WAIT; (* start step *)

Master[MASTER_INDEX].Parameter.Velocity       := 1000; (* velocity for movement *)
Master[MASTER_INDEX].Parameter.Acceleration   := 5000; (* acceleration for movement *)
Master[MASTER_INDEX].Parameter.Deceleration   := 5000; (* deceleration for movement *)
Master[MASTER_INDEX].Parameter.JogVelocity    := 400;  (* velocity for jogging *)
END_PROGRAM

