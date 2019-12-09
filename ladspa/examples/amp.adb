with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Interfaces.C.Pointers;
with System;

package body Amp is
   use type LADSPA.Data_Ptr;
   use type LADSPA.Handles;

   type Amplifiers is
      record
         Gain_Value      : LADSPA.Data_Ptr;
         Input_Buffer_1  : LADSPA.Data_Ptr;
         Output_Buffer_2 : LADSPA.Data_Ptr;
      end record;

   type Amplifier_Ptr is access all Amplifiers with
     Convention => C;

   function Convert is new Ada.Unchecked_Conversion (Source => LADSPA.Handles, Target => Amplifier_Ptr);
   function Convert is new Ada.Unchecked_Conversion (Source => Amplifier_Ptr,  Target => LADSPA.Handles);

   procedure Free is new Ada.Unchecked_Deallocation (Object => Amplifiers, Name => Amplifier_Ptr);

   --  Create and destroy handles (access to Amplifiers).
   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles
   is
      use type LADSPA.Descriptors;
   begin
      return Convert (new Amplifiers);
   end Instantiate;


   procedure Clean_Up (Instance : in LADSPA.Handles) is
      Amp : Amplifier_Ptr := null;
   begin
      if Instance /= null then
         Amp := Convert (Instance);

         if Amp = null then
            Put_Line ("Clean_Up - Amp is null");
         else
            Free (Amp);

            --  TODO: This needs to go into a controlled object.
            for C_Str_Index in Mono_Port_Numbers loop
               declare
                  C_Str : C.Strings.chars_ptr := Mono_Port_Names (C_Str_Index);
               begin
                  C.Strings.Free (C_Str);
               end;
            end loop;

            C.Strings.Free (Mono_Descriptor.Label);
            C.Strings.Free (Mono_Descriptor.Name);
            C.Strings.Free (Mono_Descriptor.Maker);
            C.Strings.Free (Mono_Descriptor.Copyright);
         end if;
      -- else
      --    Put_Line ("Clean_Up - Instance is null");
      end if;
   end Clean_Up;



   procedure Connect_Port (Instance      : in LADSPA.Handles;
                           Port          : in C.unsigned_long;
                           Data_Location : in LADSPA.Data_Ptr) is

      Amp         : Amplifier_Ptr              := Convert (Instance);
      Actual_Port : constant Mono_Port_Numbers := Mono_Port_Numbers'Val (Port);

      use type LADSPA.Handles;
   begin
      if Instance /= null then
         if Amp /= null then
            case Actual_Port is
               when Gain =>
                  Amp.Gain_Value := Data_Location;

               when Input_1 =>
                  Amp.Input_Buffer_1 := Data_Location;

               when Output_1 =>
                  Amp.Output_Buffer_2 := Data_Location;
            end case;
         end if;
      end if;

   end Connect_Port;

   -- procedure Activate (Instance : in out LADSPA.Handles) is
   -- begin
      -- Put_Line (">>> " & C.unsigned_long'Image (Mono_Descriptor.Port_Count));
   --    null;
   -- end Activate;

   -- procedure Deactivate (Instance : in out Handles) is
   -- begin
   --    null;
   -- end;

   --  WARNING: Cannot do IO or memory allocations here.
   procedure Run (Instance : in LADSPA.Handles; Sample_Count : in C.unsigned_long) is
      Amp  : Amplifier_Ptr        := Convert (Instance);
      Gain : constant LADSPA.Data := Amp.Gain_Value.all;

      package Amp_Ptrs is new Interfaces.C.Pointers
        (Index              => C.unsigned_long,
         Element            => LADSPA.Data,
         Element_Array      => LADSPA.Data_Array,
         Default_Terminator => 0.0);

      Input  : Amp_Ptrs.Pointer := Amp_Ptrs.Pointer (Amp.Input_Buffer_1);
      Output : Amp_Ptrs.Pointer := Amp_Ptrs.Pointer (Amp.Output_Buffer_2);

      use type LADSPA.Data;
   begin
      for Index in 0 .. Sample_Count loop
         Output.all := Input.all * Gain;

         Amp_Ptrs.Increment (Input);
         Amp_Ptrs.Increment (Output);
      end loop;
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

   function Descriptor (Index : C.unsigned_long) return access constant LADSPA.Descriptors is
   begin
      case Index is
         when 0 =>
            return Mono_Descriptor'Access;
         when others =>
            null;
      end case;

      return null;
   end Descriptor;
end Amp;
