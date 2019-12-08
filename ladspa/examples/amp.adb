-- with Ada.Text_IO; use Ada.Text_IO;
with System;

package body Amp is
   type Amplifiers is
      record
         Control_Value : access LADSPA.Data;
      end record;

   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles
   is
   begin
      -- Put_Line (">>> " & C.unsigned_long'Image (Mono_Descriptor.Port_Count));
      return LADSPA.Handles (System.Null_Address);
   end Instantiate;

   procedure Connect_Port (Instance      : in LADSPA.Handles;
                           Port          : in C.unsigned_long;
                           Data_Location : access LADSPA.Data) is

      Actual_Port : constant Mono_Port_Numbers := Mono_Port_Numbers'Val (Port);
   begin
      case Actual_Port is
         when Control =>
            null;
         when Input_1 =>
            null;
         when Output_1 =>
            null;
      end case;
   end Connect_Port;

   procedure Activate (Instance : in out LADSPA.Handles) is
   begin
      -- Put_Line (">>> " & C.unsigned_long'Image (Mono_Descriptor.Port_Count));
      null;
   end Activate;

   -- procedure Deactivate (Instance : in out Handles) is
   -- begin
   --    null;
   -- end;

   --  WARNING: Cannot do IO or memory allocations here.
   procedure Run (Instance : in out LADSPA.Handles; Sample_Count : in C.unsigned_long) is
   begin
      null;
   end Run;

   -- procedure Run_Adding (Instance : in out Handles; Sample_Count : in unsigned_long) is
   -- begin
   --    null;
   -- end;

   -- procedure Run_Adding_Gain (Instance : in out Handles; Gain : in Data) is
   -- begin
   --    null;
   -- end;

   procedure Clean_Up (Instance : in out LADSPA.Handles) is
   begin
      for C_Str in Mono_Port_Numbers loop
         C.Strings.Free (Mono_Port_Names (C_Str));
      end loop;

      C.Strings.Free (Mono_Descriptor.Label);
      C.Strings.Free (Mono_Descriptor.Name);
      C.Strings.Free (Mono_Descriptor.Maker);
      C.Strings.Free (Mono_Descriptor.Copyright);
   end Clean_Up;

   function Descriptor (Index : C.unsigned_long) return access constant LADSPA.Descriptors is
   begin
      -- for I in Mono_Port_Numbers'Range loop
      --    Put_Line (">>> " & Mono_Port_Numbers'Image (I) & " = " & C.unsigned_long'Image (Mono_Port_Numbers'Pos (I)));
      -- end loop;
      -- Put_Line (">>> " & C.unsigned_long'Image (Mono_Descriptor.Port_Count));
      case Index is
         when 0 =>
            return Mono_Descriptor'Access;
         when others =>
            null;
      end case;

      return null;
   end Descriptor;
end Amp;
