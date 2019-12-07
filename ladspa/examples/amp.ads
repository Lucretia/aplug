--  Amp
--
--
------------------------------------------------------------------------------------------------------------------------
with Interfaces.C;
with Interfaces.C.Strings;
with LADSPA;

package Amp is
   -- pragma Preelaborate;

   package C renames Interfaces.C;

   type Port_Numbers is (Control, Input_1, Output_1, Input_2, Output_2) with
     Convention => C;
   subtype Mono_Port_Numbers is Port_Numbers range Control .. Output_1;

   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles with
     Convention => C;

   procedure Connect_Port (Instance      : in LADSPA.Handles;
                           Port          : in C.unsigned_long;
                           Data_Location : access LADSPA.Data) with
     Convention => C;

   -- procedure Activate (Instance : in out Handles) with
   --   Convention => C;

   -- procedure Deactivate (Instance : in out Handles) with
   --   Convention => C;

   procedure Run (Instance : in out LADSPA.Handles; Sample_Count : in C.unsigned_long) with
     Convention => C;

   -- procedure Run_Adding (Instance : in out Handles; Sample_Count : in unsigned_long) with
   --   Convention => C;

   -- procedure Run_Adding_Gain (Instance : in out Handles; Gain : in Data) with
   --   Convention => C;

   procedure Clean_Up (Instance : in out LADSPA.Handles) with
     Convention => C;
private
   use type LADSPA.All_Port_Descriptors;
   use type LADSPA.Port_Range_Hint_Descriptors;

   type Mono_Port_Descriptor_Array is array (Mono_Port_Numbers) of LADSPA.All_Port_Descriptors with
     Convention => C;

   Mono_Port_Descriptors : aliased constant Mono_Port_Descriptor_Array :=
     (Control  => (LADSPA.Input or LADSPA.Control),
      Input_1  => (LADSPA.Input or LADSPA.Audio),
      Output_1 => (LADSPA.Output or LADSPA.Audio));

   type Mono_Port_Names_Array is array (Mono_Port_Numbers) of C.Strings.chars_ptr with
     Convention => C;

   Mono_Port_Names : Mono_Port_Names_Array :=
     (Control  => C.Strings.New_String ("Gain"),
      Input_1  => C.Strings.New_String ("Input"),
      Output_1 => C.Strings.New_String ("Output"));

   type Mono_Port_Range_Hints_Array is array (Mono_Port_Numbers) of LADSPA.All_Port_Range_Hints with
     Convention => C;

   Mono_Port_Range_Hints : constant Mono_Port_Range_Hints_Array :=
     (Control  => (Hint_Descriptor => LADSPA.Bounded_Below or LADSPA.Logarithmic or LADSPA.Default_1,
                   Lower_Bound     => 0.0,
                   Upper_Bound     => <>),
      Input_1  => (Hint_Descriptor => LADSPA.Default_None,
                   others          => <>),
      Output_1 => (Hint_Descriptor => LADSPA.Default_None,
                   others          => <>));

   Mono_Descriptor : aliased LADSPA.Descriptors :=
     (Unique_ID        => 1048,
      Label            => C.Strings.New_String ("amp_mono"),
      Properties       => LADSPA.Hard_RT_Capable,
      Name             => C.Strings.New_String ("Mono Amplifier"),
      Maker            => C.Strings.New_String ("Richard Furse (LADSPA example plugins) & Luke A. Guest (Ada port)"),
      Copyright        => C.Strings.New_String ("None"),
      Port_Count       => 3,
      Port_Descriptors => Mono_Port_Descriptors'Address,
      Port_Names       => Mono_Port_Names'Address,
      Port_Range_Hints => Mono_Port_Range_Hints'Address,
      Instantiate      => Instantiate'Access,
      Connect_Port     => Connect_Port'Access,
      -- Activate         => Activate'Access,
      Run              => Run'Access,
      Clean_Up         => Clean_Up'Access,
      others           => <>);

   function Descriptor (Index : C.unsigned_long) return access constant LADSPA.Descriptors with
     Export        => True,
     Convention    => C,
     External_Name => "ladspa_descriptor";
end Amp;