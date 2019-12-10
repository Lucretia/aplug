with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Interfaces;
with Interfaces.C.Pointers;
with System;

package body Delays is
   use type LADSPA.Data;
   use type LADSPA.Data_Ptr;
   use type LADSPA.Handles;

   type Buffers is array (C.unsigned_long range <>) of LADSPA.Data;
   type Buffers_Ptr is access all Buffers;

   type Simple_Delay_Line is
      record
         Sample_Rate    : LADSPA.Data;
         Buffer         : Buffers_Ptr;
         Write_Position : C.unsigned_long;

         --  Ports.
         Delay_Length   : LADSPA.Data_Ptr;
         Dry_Wet        : LADSPA.Data_Ptr;
         Output_Buffer  : LADSPA.Data_Ptr;
         Input_Buffer   : LADSPA.Data_Ptr;
      end record;

   type Simple_Delay_Line_Ptr is access all Simple_Delay_Line with
     Convention => C;

   function Convert is new Ada.Unchecked_Conversion (Source => LADSPA.Handles,        Target => Simple_Delay_Line_Ptr);
   function Convert is new Ada.Unchecked_Conversion (Source => Simple_Delay_Line_Ptr, Target => LADSPA.Handles);

   procedure Free is new Ada.Unchecked_Deallocation (Object => Simple_Delay_Line, Name => Simple_Delay_Line_Ptr);
   procedure Free is new Ada.Unchecked_Deallocation (Object => Buffers, Name => Buffers_Ptr);

   --  Create and destroy handles (access to Amplifiers).
   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles
   is
      use type LADSPA.Descriptors;

      Delay_Line  : access Simple_Delay_Line := null;
      Min_Buffer  : C.unsigned_long          := 0;
      Buffer_Size : C.unsigned_long          := 1;
   begin
      Delay_Line := new Simple_Delay_Line'(Write_Position => 0, others => <>);

      if Delay_Line = null then
         return null;
      end if;

      Delay_Line.Sample_Rate := LADSPA.Data (Sample_Rate);

      --  Buffer size is a power of two bigger than max delay time.
      Min_Buffer := C.unsigned_long (LADSPA.Data (Sample_Rate) * Max_Delay);

      while Buffer_Size < Min_Buffer loop
         Buffer_Size := C.unsigned_long (Interfaces.Shift_Left (Interfaces.Unsigned_64 (Buffer_Size), 1));
      end loop;

      Delay_Line.Buffer := new Buffers (0 .. Buffer_Size);

      if Delay_Line.Buffer = null then
         Free (Delay_Line);

         return null;
      end if;

      -- Put_Line ("Min_Buffer       : " & C.unsigned_long'Image (Min_Buffer));
      -- Put_Line ("Delay_Line.Buffer: " & C.unsigned_long'Image (Delay_Line.Buffer'Length));

      return Convert (Delay_Line);
   end Instantiate;


   procedure Clean_Up (Instance : in LADSPA.Handles) is
      Delays : Simple_Delay_Line_Ptr := null;
   begin
      if Instance /= null then
         Delays := Convert (Instance);

         if Delays /= null then
            Free (Delays.Buffer);
            Free (Delays);
         -- else
         --    Put_Line ("Clean_Up - Delays is null");
         end if;
      -- else
      --    Put_Line ("Clean_Up - Instance is null");
      end if;
   end Clean_Up;



   procedure Connect_Port (Instance      : in LADSPA.Handles;
                           Port          : in C.unsigned_long;
                           Data_Location : in LADSPA.Data_Ptr) is

      Delays      : Simple_Delay_Line_Ptr := Convert (Instance);
      Actual_Port : constant Port_Numbers := Port_Numbers'Val (Port);
   begin
      if Instance /= null then
         if Delays /= null then
            case Actual_Port is
               when Delay_Length =>
                  Delays.Delay_Length := Data_Location;

               when Dry_Wet =>
                  Delays.Dry_Wet := Data_Location;

               when Input =>
                  Delays.Input_Buffer := Data_Location;

               when Output =>
                  Delays.Output_Buffer := Data_Location;
            end case;
         end if;
      end if;

   end Connect_Port;

   -- procedure Activate (Instance : in out LADSPA.Handles) is
   -- begin
      -- Put_Line (">>> " & C.unsigned_long'Image (Descriptor.Port_Count));
   --    null;
   -- end Activate;

   -- procedure Deactivate (Instance : in out Handles) is
   -- begin
   --    null;
   -- end;

   --  WARNING: Cannot do IO or memory allocations here.
   procedure Run (Instance : in LADSPA.Handles; Sample_Count : in C.unsigned_long) is
      use type LADSPA.Data;

      function Limit_Between_0_And_1 (Value : in LADSPA.Data) return LADSPA.Data is
        (if Value < 0.0 then 0.0 else (if Value > 1.0 then 1.0 else Value));

      function Limit_Between_0_And_Max_Delay (Value : in LADSPA.Data) return LADSPA.Data is
        (if Value < 0.0 then 0.0 else (if Value > LADSPA.Data (Max_Delay) then LADSPA.Data (Max_Delay) else Value));

      package Delay_Ptrs is new Interfaces.C.Pointers
        (Index              => C.unsigned_long,
         Element            => LADSPA.Data,
         Element_Array      => LADSPA.Data_Array,
         Default_Terminator => 0.0);

      Delays              : Simple_Delay_Line_Ptr := Convert (Instance);
      Buffer_Size_Minus_1 : C.unsigned_long       := Delays.Buffer'Length - 1;
      Delay_Length        : C.unsigned_long       :=
        C.unsigned_long (Limit_Between_0_And_Max_Delay (Delays.Delay_Length.all) * Delays.Sample_Rate);
      Input               : Delay_Ptrs.Pointer    := Delay_Ptrs.Pointer (Delays.Input_Buffer);
      Output              : Delay_Ptrs.Pointer    := Delay_Ptrs.Pointer (Delays.Output_Buffer);
      Write_Offset        : C.unsigned_long       := Delays.Write_Position;
      Read_Offset         : C.unsigned_long       := Write_Offset + Delays.Buffer'Length - Delay_Length;
      Wet                 : LADSPA.Data           := Limit_Between_0_And_1 (Delays.Dry_Wet.all);
      Dry                 : LADSPA.Data           := 1.0 - Wet;
      Input_Sample        : LADSPA.Data           := 0.0;

      use type LADSPA.Data;
   begin
      -- Put_Line ("Buffer length : " & C.unsigned_long'Image (Delays.Buffer'Length) & " - " & C.unsigned_long'Image (Buffer_Size_Minus_1));
      -- Put_Line ("Delay_Length : " & LADSPA.Data'Image (Delays.Delay_Length.all));
      -- Put_Line ("Wet : " & LADSPA.Data'Image (Wet));
      -- Put_Line ("Dry : " & LADSPA.Data'Image (Dry));
      -- Put_Line ("Write_Offset : " & C.unsigned_long'Image (Write_Offset));
      -- Put_Line ("Read_Offset : " & C.unsigned_long'Image (Read_Offset));
      for Index in 0 .. Sample_Count loop
         Input_Sample := Input.all;
         -- Put_Line ("Input_Sample : " & LADSPA.Data'Image (Input_Sample));
         -- Put_Line ("Index : " & C.unsigned_long'Image (Index));
         -- Put_Line ("Buffer Index : " & C.unsigned_long'Image (Index + Read_Offset));
         -- delay 2.0;

         --  TODO: This calculation gets zero no matter what.
         -- Put_Line (">> " & C.unsigned_long'Image (C.unsigned_long (Index + Read_Offset) and Buffer_Size_Minus_1));
         Output.all := ((Dry * Input_Sample) + (Wet *
           Delays.Buffer (C.unsigned_long (Index + Read_Offset) and Buffer_Size_Minus_1)));
         Delays.Buffer ((Index + Write_Offset) and Buffer_Size_Minus_1) := Input_Sample;

         Delay_Ptrs.Increment (Input);
         Delay_Ptrs.Increment (Output);
      end loop;

      Delays.Write_Position := ((Delays.Write_Position + Sample_Count) and Buffer_Size_Minus_1);
   exception
      when others =>
         null;  --  Silently catch for now.
   end Run;

   -- procedure Run_Adding (Instance : in out Handles; Sample_Count : in unsigned_long) is
   -- begin
   --    null;
   -- end;

   -- procedure Run_Adding_Gain (Instance : in out Handles; Gain : in Data) is
   -- begin
   --    null;
   -- end;

   overriding procedure Finalize (Self : in out Descriptors) is
      C_Str : C.Strings.chars_ptr;
   begin
      for C_Str_Index in Port_Numbers loop
         C_Str := Port_Names (C_Str_Index);

         C.Strings.Free (C_Str);
      end loop;
   end Finalize;


   function Descriptor (Index : C.unsigned_long) return access constant LADSPA.Descriptors is
   begin
      if Index = 0 then
         return Delay_Descriptor.Data'Access;
      end if;

      return null;
   end Descriptor;
end Delays;
