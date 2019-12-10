-- with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Interfaces.C.Pointers;
with System;

package body Amp.Stereo is
   use type LADSPA.Data_Ptr;
   use type LADSPA.Handles;

   type Amplifiers is
      record
         Gain_Value      : LADSPA.Data_Ptr;
         Input_Buffer_1  : LADSPA.Data_Ptr;
         Output_Buffer_1 : LADSPA.Data_Ptr;
         Input_Buffer_2  : LADSPA.Data_Ptr;
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

         if Amp /= null then
            Free (Amp);
         -- else
         --    Put_Line ("Clean_Up - Amp is null");
         end if;
      -- else
      --    Put_Line ("Clean_Up - Instance is null");
      end if;
   end Clean_Up;



   procedure Connect_Port (Instance      : in LADSPA.Handles;
                           Port          : in C.unsigned_long;
                           Data_Location : in LADSPA.Data_Ptr) is

      Amp         : Amplifier_Ptr         := Convert (Instance);
      Actual_Port : constant Port_Numbers := Port_Numbers'Val (Port);

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
                  Amp.Output_Buffer_1 := Data_Location;

               when Input_2 =>
                  Amp.Input_Buffer_2 := Data_Location;

               when Output_2 =>
                  Amp.Output_Buffer_2 := Data_Location;
            end case;
         end if;
      end if;

   end Connect_Port;

   -- procedure Activate (Instance : in out LADSPA.Handles) is
   -- begin
      -- Put_Line (">>> " & C.unsigned_long'Image (Stereo_Descriptor.Port_Count));
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

      Input_Left   : Amp_Ptrs.Pointer := Amp_Ptrs.Pointer (Amp.Input_Buffer_1);
      Output_Left  : Amp_Ptrs.Pointer := Amp_Ptrs.Pointer (Amp.Output_Buffer_1);
      Input_Right  : Amp_Ptrs.Pointer := Amp_Ptrs.Pointer (Amp.Input_Buffer_2);
      Output_Right : Amp_Ptrs.Pointer := Amp_Ptrs.Pointer (Amp.Output_Buffer_2);

      use type LADSPA.Data;
   begin
      for Index in 0 .. Sample_Count loop
         Output_Left.all  := Input_Left.all * Gain;
         Output_Right.all := Input_Right.all * Gain;

         Amp_Ptrs.Increment (Input_Left);
         Amp_Ptrs.Increment (Output_Left);

         Amp_Ptrs.Increment (Input_Right);
         Amp_Ptrs.Increment (Output_Right);
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


   overriding procedure Finalize (Self : in out Stereo_Descriptors) is
      C_Str : C.Strings.chars_ptr;
   begin
      for C_Str_Index in Port_Numbers loop
         C_Str := Stereo_Port_Names (C_Str_Index);

         C.Strings.Free (C_Str);
      end loop;
   end Finalize;
end Amp.Stereo;