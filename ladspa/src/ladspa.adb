package body LADSPA is
   overriding procedure Finalize (Self : in out Root_Descriptors) is
      C_Str : C.Strings.chars_ptr;
   begin
      C_Str := Self.Data.Label;

      C.Strings.Free (C_Str);

      C_Str := Self.Data.Name;

      C.Strings.Free (C_Str);

      C_Str := Self.Data.Maker;

      C.Strings.Free (C_Str);

      C_Str := Self.Data.Copyright;

      C.Strings.Free (C_Str);
   end Finalize;
end LADSPA;