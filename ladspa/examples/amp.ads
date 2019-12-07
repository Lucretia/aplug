--  Amp
--
--
------------------------------------------------------------------------------------------------------------------------
with Interfaces.C;
with LADSPA;

package Amp is
   pragma Preelaborate;

   package C renames Interfaces.C;

   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles with
     Convention => C;
end Amp;