--  Amp.Stereo
--
--
------------------------------------------------------------------------------------------------------------------------
with Ada.Finalization;
with Interfaces.C;
with Interfaces.C.Strings;
with LADSPA;

private package Amp.Stereo is
   package C renames Interfaces.C;

   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles with
     Convention => C;

   procedure Clean_Up (Instance : in LADSPA.Handles) with
     Convention => C;


   procedure Connect_Port (Instance      : in LADSPA.Handles;
                           Port          : in C.unsigned_long;
                           Data_Location : in LADSPA.Data_Ptr) with
     Convention => C;

   -- procedure Activate (Instance : in out Handles) with
   --   Convention => C;

   -- procedure Deactivate (Instance : in out Handles) with
   --   Convention => C;

   procedure Run (Instance : in LADSPA.Handles; Sample_Count : in C.unsigned_long) with
     Convention => C;

   -- procedure Run_Adding (Instance : in out Handles; Sample_Count : in unsigned_long) with
   --   Convention => C;

   -- procedure Run_Adding_Gain (Instance : in out Handles; Gain : in Data) with
   --   Convention => C;
-- private
   use type LADSPA.All_Port_Descriptors;
   use type LADSPA.Port_Range_Hint_Descriptors;

   package Stereo_Ports is new LADSPA.Port_Information (Port_Type => Port_Numbers);

   Stereo_Port_Descriptors : aliased constant Stereo_Ports.Descriptor_Array :=
     (Gain     => (LADSPA.Input or LADSPA.Control),
      Input_1  => (LADSPA.Input or LADSPA.Audio),
      Output_1 => (LADSPA.Output or LADSPA.Audio),
      Input_2  => (LADSPA.Input or LADSPA.Audio),
      Output_2 => (LADSPA.Output or LADSPA.Audio));

   Stereo_Port_Names : constant Stereo_Ports.Name_Array :=
     (Gain     => C.Strings.New_String ("Gain"),
      Input_1  => C.Strings.New_String ("Input (Left)"),
      Output_1 => C.Strings.New_String ("Output (Left)"),
      Input_2  => C.Strings.New_String ("Input (Right)"),
      Output_2 => C.Strings.New_String ("Output (Right)"));

   Stereo_Port_Range_Hints : constant Stereo_Ports.Range_Hint_Array :=
     (Gain     => (Hint_Descriptor => LADSPA.Bounded_Below or LADSPA.Logarithmic or LADSPA.Default_1,
                   Lower_Bound     => 0.0,
                   Upper_Bound     => <>),
      Input_1  => (Hint_Descriptor => LADSPA.Default_None,
                   others          => <>),
      Output_1 => (Hint_Descriptor => LADSPA.Default_None,
                   others          => <>),
      Input_2  => (Hint_Descriptor => LADSPA.Default_None,
                   others          => <>),
      Output_2 => (Hint_Descriptor => LADSPA.Default_None,
                   others          => <>));

   use type Interfaces.C.unsigned_long;

   --  This is required so that on finalisation of the library (unload), the globally allocated data is destroyed.
   type Stereo_Descriptors is new LADSPA.Root_Descriptors with null record;

   overriding procedure Finalize (Self : in out Stereo_Descriptors);

   Stereo_Descriptor : constant Stereo_Descriptors := (Ada.Finalization.Limited_Controlled with
      Data => (
        Unique_ID        => 1049,
        Label            => C.Strings.New_String ("amp_stereo"),
        Properties       => LADSPA.Hard_RT_Capable,
        Name             => C.Strings.New_String ("Stereo Amplifier"),
        Maker            => C.Strings.New_String ("Richard Furse (LADSPA example plugins) & Luke A. Guest (Ada port)"),
        Copyright        => C.Strings.New_String ("None"),
        Port_Count       => Port_Numbers'Pos (Port_Numbers'Last) + 1,  --  Pos starts at 0!
        Port_Descriptors => Stereo_Port_Descriptors'Address,
        Port_Names       => Stereo_Port_Names (Stereo_Port_Names'First)'Access,
        Port_Range_Hints => Stereo_Port_Range_Hints'Address,
        Instantiate      => Instantiate'Access,
        Connect_Port     => Connect_Port'Access,
        -- Activate         => Activate'Access,
        Run              => Run'Access,
        Clean_Up         => Clean_Up'Access,
        others           => <>
      ));
end Amp.Stereo;