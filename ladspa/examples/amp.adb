with System;

package body Amp is
   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles
   is
   begin
      return LADSPA.Handles (System.Null_Address);
   end Instantiate;

end Amp;
