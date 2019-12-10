--  with Interfaces.C.Strings;
with Amp.Mono;
with Amp.Stereo;

package body Amp is
   function Descriptor (Index : C.unsigned_long) return access constant LADSPA.Descriptors is
   begin
      case Index is
         when 0 =>
            return Amp.Mono.Mono_Descriptor.Data'Access;

         when 1 =>
            return Amp.Stereo.Stereo_Descriptor.Data'Access;

         when others =>
            null;
      end case;

      return null;
   end Descriptor;
end Amp;
