--  Amp
--
--  Amplifier LADSPA plugin.
------------------------------------------------------------------------------------------------------------------------
--  with Ada.Finalization;
with Interfaces.C;
with LADSPA;

package Amp is
   type Port_Numbers is (Gain, Input_1, Output_1, Input_2, Output_2) with
     Convention => C;
private
   package C renames Interfaces.C;

   function Descriptor (Index : C.unsigned_long) return access constant LADSPA.Descriptors with
     Export        => True,
     Convention    => C,
     External_Name => "ladspa_descriptor";
end Amp;