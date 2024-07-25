(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Program: Axis_00
 * File: axisInit.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 ********************************************************************
 * Implementation of program Axis_00
 ********************************************************************)

PROGRAM _INIT
AxisStep := STATE_WAIT; (* start step *)

Axis[AXIS_INDEX].Parameter.Velocity       := 1000; (* velocity for movement *)
Axis[AXIS_INDEX].Parameter.Acceleration   := 5000; (* acceleration for movement *)
Axis[AXIS_INDEX].Parameter.Deceleration   := 5000; (* deceleration for movement *)
Axis[AXIS_INDEX].Parameter.JogVelocity    := 400;  (* velocity for jogging *)
END_PROGRAM

