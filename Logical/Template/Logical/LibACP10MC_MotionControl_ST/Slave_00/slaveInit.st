(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: Slave_00
 * File: slaveInit.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program Slave_00
 ********************************************************************)

PROGRAM _INIT
SlaveStep := STATE_WAIT; (* start step *)

Slave[SLAVE_INDEX].Parameter.Velocity       := 1000; (* velocity for movement *)
Slave[SLAVE_INDEX].Parameter.Acceleration   := 5000; (* acceleration for movement *)
Slave[SLAVE_INDEX].Parameter.Deceleration   := 5000; (* deceleration for movement *)
Slave[SLAVE_INDEX].Parameter.JogVelocity    := 400;  (* velocity for jogging *)
END_PROGRAM

