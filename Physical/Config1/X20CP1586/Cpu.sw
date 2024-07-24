<?xml version="1.0" encoding="utf-8"?>
<?AutomationStudio FileVersion="4.9"?>
<SwConfiguration CpuAddress="SL1" xmlns="http://br-automation.co.at/AS/SwConfiguration">
  <TaskClass Name="Cyclic#1" />
  <TaskClass Name="Cyclic#2" />
  <TaskClass Name="Cyclic#3" />
  <TaskClass Name="Cyclic#4">
    <Task Name="Reel_A" Source="MotionControl.AxisControl.Reel_A.prg" Memory="UserROM" Language="IEC" Debugging="true" />
    <Task Name="Reel_B" Source="MotionControl.AxisControl.Reel_B.prg" Memory="UserROM" Language="IEC" Debugging="true" />
  </TaskClass>
  <NcDataObjects>
    <NcDataObject Name="acp10etxen" Source="AxisObject.acp10etxen.dob" Memory="UserROM" Language="Ett" />
    <NcDataObject Name="VAxInit" Source="AxisObject.VirtualAxis.VAxInit.dob" Memory="UserROM" Language="Vax" />
    <NcDataObject Name="AcpParTab" Source="AxisObject.RealAxis.AcpParTab.dob" Memory="UserROM" Language="Apt" />
    <NcDataObject Name="AxInit" Source="AxisObject.RealAxis.AxInit.dob" Memory="UserROM" Language="Ax" />
  </NcDataObjects>
  <Libraries>
    <LibraryObject Name="Acp10man" Source="Libraries.Acp10man.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Acp10par" Source="Libraries.Acp10par.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="NcGlobal" Source="Libraries.NcGlobal.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="Acp10sim" Source="Libraries.Acp10sim.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="Acp10_MC" Source="Libraries.Acp10_MC.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="sys_lib" Source="Libraries.sys_lib.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="brsystem" Source="Libraries.brsystem.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="runtime" Source="Libraries.runtime.lby" Memory="UserROM" Language="binary" Debugging="true" />
    <LibraryObject Name="MpAxis" Source="Libraries.MpAxis.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="MpBase" Source="Libraries.MpBase.lby" Memory="UserROM" Language="Binary" Debugging="true" />
    <LibraryObject Name="MpCom" Source="Libraries.MpCom.lby" Memory="UserROM" Language="Binary" Debugging="true" />
  </Libraries>
</SwConfiguration>