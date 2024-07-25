(********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * PROGRAM: Slave
 * File: Labeler.st
 * Author: Bernecker + Rainer
 * Created: March 01, 2011
 *******************************************************************)

FUNCTION Labeler
    (*general automat parameter*)
        AutData.Master              := Axis;
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

        AutData.State[1].Event[0].Type      := ncTRIGGER1+ncP_EDGE;
        AutData.State[1].Event[0].Attribute := ncST_END;
        AutData.State[1].Event[0].NextState := 2;

        AutData.State[1].Event[1].Type      := ncST_END;
        AutData.State[1].Event[1].Attribute := ncST_END;
        AutData.State[1].Event[1].NextState := 1;


    (*Automat STATE 2 Labeling with half compensation*)
        AutData.State[2].CamProfileIndex    := 16#FFFF;
        AutData.State[2].MasterFactor       := 200;
        AutData.State[2].SlaveFactor        := 200;
        AutData.State[2].CompMode           := ncONLYCOMP;
        AutData.State[2].MasterCompDistance := 800;
        AutData.State[2].SlaveCompDistance  := 400;

        AutData.State[2].Event[0].Type      := ncTRIGGER1+ncP_EDGE;
        AutData.State[2].Event[0].Attribute := ncST_END;
        AutData.State[2].Event[0].NextState := 3;

        AutData.State[2].Event[1].Type      := ncST_END;
        AutData.State[2].Event[1].Attribute := ncST_END;
        AutData.State[2].Event[1].NextState := 4;


    (*Automat STATE 3 Labeling *)
        AutData.State[3].CamProfileIndex    := 16#FFFF;
        AutData.State[3].MasterFactor       := 200;
        AutData.State[3].SlaveFactor        := 200;
        AutData.State[3].CompMode           := ncONLYCOMP;
        AutData.State[3].MasterCompDistance := 800;
        AutData.State[3].SlaveCompDistance  := 800;

        AutData.State[3].Event[0].Type      := ncTRIGGER1+ncP_EDGE;
        AutData.State[3].Event[0].Attribute := ncST_END;
        AutData.State[3].Event[0].NextState := 3;
		
        AutData.State[3].Event[1].Type      := ncST_END;
		AutData.State[3].Event[1].Attribute := ncST_END;
		AutData.State[3].Event[1].NextState := 4;

    (*Automat STATE 4 Return to starting position*)
        AutData.State[4].CamProfileIndex    := 16#FFFF;
        AutData.State[4].MasterFactor       := 200;
        AutData.State[4].SlaveFactor        := 0;
        AutData.State[4].CompMode           := ncONLYCOMP;
        AutData.State[4].MasterCompDistance := 800;
        AutData.State[4].SlaveCompDistance  := 400;
		
        AutData.State[4].Event[0].Type      := ncTRIGGER1+ncP_EDGE;
        AutData.State[4].Event[0].Attribute := ncST_END;
        AutData.State[4].Event[0].NextState := 2;
     
        AutData.State[4].Event[1].Type      := ncST_END;
        AutData.State[4].Event[1].Attribute := ncST_END;
        AutData.State[4].Event[1].NextState := 1;

        Labeler := TRUE;
END_FUNCTION
