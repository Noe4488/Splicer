(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * PROGRAM: Slave
 * File: FlyingSaw.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 *******************************************************************)


FUNCTION FlyingSaw
    (*general automat parameters*)
        AutData.Master              := Axis;
        AutData.StartPosition       := 0;
        AutData.StartInterval       := 1000;
        AutData.MaxMasterVelocity   := 1000;

    (*Automat STATE 0 Basis State*)
        AutData.State[0].Event[0].Type      := ncST_END;
        AutData.State[0].Event[0].Attribute := ncAT_ONCE;
        AutData.State[0].Event[0].NextState := 1;

    (*Automat STATE 1 Standstill*)
        AutData.State[1].CamProfileIndex    := 16#FFFF;
        AutData.State[1].MasterFactor       := 200;
        AutData.State[1].SlaveFactor        := 0;
        AutData.State[1].CompMode           := ncONLYCOMP;
        AutData.State[1].MasterCompDistance := 800;
        AutData.State[1].SlaveCompDistance  := 0;

        AutData.State[1].Event[0].Type      := ncS_START;
        AutData.State[1].Event[0].Attribute := ncAT_ONCE;
        AutData.State[1].Event[0].NextState := 2;

    (*Autoamt STATE 2 Synchronous movement*)
        AutData.State[2].CamProfileIndex    := 16#FFFF;
        AutData.State[2].MasterFactor       := 500;
        AutData.State[2].SlaveFactor        := 500;
        AutData.State[2].CompMode           := ncONLYCOMP;
        AutData.State[2].MasterCompDistance := 100;
        AutData.State[2].SlaveCompDistance  := 100;

        AutData.State[2].Event[0].Type      := ncST_END;
        AutData.State[2].Event[0].Attribute := ncST_END;
        AutData.State[2].Event[0].NextState := 3;

    (*Automat STATE 3 Return to starting position*)
        AutData.State[3].CamProfileIndex    := 16#FFFF;
        AutData.State[3].MasterFactor       := 100;
        AutData.State[3].SlaveFactor        := 0;
        AutData.State[3].CompMode           := ncONLYCOMP;
        AutData.State[3].MasterCompDistance := 800;
        AutData.State[3].SlaveCompDistance  := -600;

        AutData.State[3].Event[0].Type      := ncST_END;
        AutData.State[3].Event[0].Attribute := ncST_END;
        AutData.State[3].Event[0].NextState := 1;

        FlyingSaw := TRUE;
END_FUNCTION
