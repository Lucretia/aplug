pragma Restrictions (No_Allocators);
pragma Restrictions (No_IO);

separate (Amp)
procedure Run (Instance : in out LADSPA.Handles; Sample_Count : in C.unsigned_long) is
begin
   null;
end Run;

