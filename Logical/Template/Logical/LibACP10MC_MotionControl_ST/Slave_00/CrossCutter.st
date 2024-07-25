(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * PROGRAM: Slave
 * File: CrossCutter.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 *******************************************************************)


FUNCTION CrossCutter
    (*general automat parameter*)
        AutData.Master              := Axis;
        AutData.MaxMasterVelocity   := 1000;

    (*Automat STATE 0 Basis State*)
        AutData.State[0].Event[0].Type      := ncST_END;
        AutData.State[0].Event[0].Attribute := ncAT_ONCE;
        AutData.State[0].Event[0].NextState := 1;

    (*Automat STATE 1 Standstill*)
        AutData.State[1].CamProfileIndex    := 16#FFFE;
        AutData.State[1].MasterFactor       := 200;
        AutData.State[1].SlaveFactor        := 0;
        AutData.State[1].CompMode           := ncWITH_CAM;
        AutData.State[1].MasterCompDistance := 1000;
        AutData.State[1].SlaveCompDistance  := 0;

        AutData.State[1].Event[0].Type      := ncSIGNAL1;
        AutData.State[1].Event[0].Attribute := ncAT_ONCE;
        AutData.State[1].Event[0].NextState := 2;

    (*Automat STATE 2 Move Slave to Cutting Position*)
        AutData.State[2].CamProfileIndex    := 16#FFFF;
        AutData.State[2].MasterFactor       := 200;
        AutData.State[2].SlaveFactor        := 200;
        AutData.State[2].CompMode           := ncWITH_CAM;
        AutData.State[2].MasterCompDistance := 500;
        AutData.State[2].SlaveCompDistance  := 1800;

        AutData.State[2].Event[0].Type      := ncST_END;
        AutData.State[2].Event[0].Attribute := ncST_END;
        AutData.State[2].Event[0].NextState := 3;

    (*Automat STATE 3 Execute one cut every master period*)
        AutData.State[3].CamProfileIndex    := 16#FFFF;
        AutData.State[3].MasterFactor       := 200;
        AutData.State[3].SlaveFactor        := 200;
        AutData.State[3].CompMode           := ncWITH_CAM;
        AutData.State[3].MasterCompDistance := 1000;
        AutData.State[3].SlaveCompDistance  := 3600;

        AutData.State[3].Event[0].Type      := ncSIGNAL2;
        AutData.State[3].Event[0].Attribute := ncST_END;
        AutData.State[3].Event[0].NextState := 4;

        AutData.State[3].Event[1].Type      := ncST_END;
        AutData.State[3].Event[1].Attribute := ncST_END;
        AutData.State[3].Event[1].NextState := 3;

    (*Automat STATE 4 Stop Motion at Starting Point*)
        AutData.State[4].CamProfileIndex    := 16#FFFF;
        AutData.State[4].MasterFactor       := 200;
        AutData.State[4].SlaveFactor        := 0;
        AutData.State[4].CompMode           := ncWITH_CAM;
        AutData.State[4].MasterCompDistance := 500;
        AutData.State[4].SlaveCompDistance  := 1800;

        AutData.State[4].Event[0].Type      := ncST_END;
        AutData.State[4].Event[0].Attribute := ncST_END;
        AutData.State[4].Event[0].NextState := 1;

        CrossCutter := TRUE;
END_FUNCTION
