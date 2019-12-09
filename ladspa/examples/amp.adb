with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Interfaces.C.Pointers;
with System;
with System.Address_Image;
with System.Address_To_Access_Conversions;

package body Amp is
   use type LADSPA.Data_Ptr;

   type Amplifiers is
      record
         Control_Value   : LADSPA.Data_Ptr;
         Input_Buffer_1  : LADSPA.Data_Ptr;
         Output_Buffer_2 : LADSPA.Data_Ptr;
      end record;

   type Amplifier_Ptr is access all Amplifiers with
     Convention => C;

   function To_Address (Ptr : in LADSPA.Data_Ptr) return System.Address is
      package Data_Conversions is new System.Address_To_Access_Conversions (LADSPA.Data);
   begin
      return Data_Conversions.To_Address (Data_Conversions.Object_Pointer (Ptr));
   end To_Address;

   function Image (Ptr : in LADSPA.Data_Ptr) return String is (System.Address_Image (To_Address (Ptr)));

   -- package Amp_Conversions is new System.Address_To_Access_Conversions (Amplifiers);
   function Convert is new Ada.Unchecked_Conversion (Source => LADSPA.Handles, Target => Amplifier_Ptr);
   function Convert is new Ada.Unchecked_Conversion (Source => Amplifier_Ptr,  Target => LADSPA.Handles);

   -- procedure Free is new Ada.Unchecked_Deallocation (Object => Amplifiers, Name => Amp_Conversions.Object_Pointer);
   procedure Free is new Ada.Unchecked_Deallocation (Object => Amplifiers, Name => Amplifier_Ptr);

   --  Create and destroy handles (access to Amplifiers).
   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles
   is
      use type LADSPA.Descriptors;
   begin
      -- return LADSPA.Handles (Amp_Conversions.To_Address (new Amplifiers));
      return Convert (new Amplifiers);
   end Instantiate;


   procedure Clean_Up (Instance : in LADSPA.Handles) is
      -- Amp : Amp_Conversions.Object_Pointer := Amp_Conversions.To_Pointer (System.Address (Instance));
      Amp : Amplifier_Ptr := null;

      use type LADSPA.Handles;
   begin
      if Instance = null then
         Put_Line ("Clean_Up - Instance is null");
      else
         Amp := Convert (Instance);

         if Amp = null then
            Put_Line ("Clean_Up - Amp is null");
         else
            Free (Amp);

            --  TODO: This needs to go into a controlled object.
            for C_Str in Mono_Port_Numbers loop
               C.Strings.Free (Mono_Port_Names (C_Str));
            end loop;

            C.Strings.Free (Mono_Descriptor.Label);
            C.Strings.Free (Mono_Descriptor.Name);
            C.Strings.Free (Mono_Descriptor.Maker);
            C.Strings.Free (Mono_Descriptor.Copyright);
         end if;
      end if;
   end Clean_Up;



   procedure Connect_Port (Instance      : in LADSPA.Handles;
                           Port          : in C.unsigned_long;
                           Data_Location : in LADSPA.Data_Ptr) is

      -- Amp         : Amp_Conversions.Object_Pointer := Amp_Conversions.To_Pointer (System.Address (Instance));
      Amp         : Amplifier_Ptr              := Convert (Instance);
      Actual_Port : constant Mono_Port_Numbers := Mono_Port_Numbers'Val (Port);

      use type LADSPA.Handles;
   begin
      Put_Line ("Connect_Port - Port # " & C.unsigned_long'Image (Port) & " - " & Mono_Port_Numbers'Image (Actual_Port));

      if Instance = null then
         Put_Line ("Connect_Port - Instance is null");
      end if;

      if Amp /= null then
         case Actual_Port is
            when Control =>
               if Data_Location /= null then
                  -- Put_Line ("Control: " & System.Address_Image (Data_Conversions.To_Address (Data_Location)));
                  Put_Line ("Connect_Port - Control: " & Image (Data_Location));
               else
                  Put_Line ("Connect_Port - Control = NULLLLL!!!!");
               end if;
               Amp.Control_Value := Data_Location;

            when Input_1 =>
               if Data_Location /= null then
                  -- Put_Line ("Control: " & System.Address_Image (Data_Conversions.To_Address (Data_Location)));
                  Put_Line ("Connect_Port - Input_1: " & Image (Data_Location));
               else
                  Put_Line ("Connect_Port - Input_1 = NULLLLL!!!!");
               end if;
               Amp.Input_Buffer_1 := Data_Location;

            when Output_1 =>
               if Data_Location /= null then
                  -- Put_Line ("Control: " & System.Address_Image (Data_Conversions.To_Address (Data_Location)));
                  Put_Line ("Connect_Port - Output_1: " & Image (Data_Location));
               else
                  Put_Line ("Connect_Port - Output_1 = NULLLLL!!!!");
               end if;
               Amp.Output_Buffer_2 := Data_Location;
         end case;
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
      -- Amp  : Amp_Conversions.Object_Pointer := null; --  Amp_Conversions.To_Pointer (System.Address (Instance));
      Amp : Amplifier_Ptr := null;
      use type LADSPA.Handles;
      -- use type Amp_Conversions.Object_Pointer;
      -- Gain : constant LADSPA.Data           := Amp.Control_Value.all;

      -- package Amp_Ptrs is new Interfaces.C.Pointers
      --   (Index              => C.unsigned_long,
      --    Element            => LADSPA.Data,
      --    Element_Array      => LADSPA.Data_Array,
      --    Default_Terminator => 0.0);

      -- Input  : Amp_Ptrs.Pointer := Amp_Ptrs.Pointer (Amp.Input_Buffer_1);
      -- Output : Amp_Ptrs.Pointer := Amp_Ptrs.Pointer (Amp.Output_Buffer_2);

      -- use type C.C_float;
   begin
      if Instance /= null then
         -- Amp := Amp_Conversions.To_Pointer (System.Address (Instance));
         Amp := Convert (Instance);

         if Amp /= null then
            null;
         --    if Amp.Control_Value /= null then
         --       Put_Line ("Run - Control_Value: " & Image (Amp.Control_Value));
         --    else
         --       Put_Line ("Run - Control_Value = NULLLLL!!!!");
         --    end if;

         --    if Amp.Input_Buffer_1 /= null then
         --       -- Put_Line ("Control: " & System.Address_Image (Data_Conversions.To_Address (Data_Location)));
         --       Put_Line ("Run - Input_1: " & Image (Amp.Input_Buffer_1));
         --    else
         --       Put_Line ("Run - Input_1 = NULLLLL!!!!");
         --    end if;

         --    if Amp.Output_Buffer_2 /= null then
         --       -- Put_Line ("Control: " & System.Address_Image (Data_Conversions.To_Address (Data_Location)));
         --       Put_Line ("Run - Output_1: " & Image (Amp.Output_Buffer_2));
         --    else
         --       Put_Line ("Run - Output_1 = NULLLLL!!!!");
         --    end if;
         end if;
      end if;
      -- for Index in 0 .. Sample_Count loop
      --    Output.all := Input.all * Gain;

      --    Amp_Ptrs.Increment (Input);
      --    Amp_Ptrs.Increment (Output);
      -- end loop;
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
