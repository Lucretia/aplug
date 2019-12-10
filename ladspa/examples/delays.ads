--  Delays
--
--  Delay LADSPA plugin.
------------------------------------------------------------------------------------------------------------------------
--  with Ada.Finalization;
with Ada.Finalization;
with Interfaces.C;
with Interfaces.C.Strings;
with LADSPA;

package Delays is
   package C renames Interfaces.C;

   type Port_Numbers is (Delay_Length, Dry_Wet, Input, Output) with
     Convention => C;
private
   function Instantiate (Descriptor  : access constant LADSPA.Descriptors;
                         Sample_Rate : C.unsigned_long) return LADSPA.Handles with
     Convention => C;

   procedure Clean_Up (Instance : in LADSPA.Handles) with
     Convention => C;


   procedure Connect_Port (Instance      : in LADSPA.Handles;
                           Port          : in C.unsigned_long;
                           Data_Location : in LADSPA.Data_Ptr) with
     Convention => C;

   procedure Activate (Instance : in LADSPA.Handles) with
     Convention => C;

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

   package Ports is new LADSPA.Port_Information (Port_Type => Port_Numbers);

   Max_Delay : constant := 5.0;

   Port_Descriptors : aliased constant Ports.Descriptor_Array :=
     (Delay_Length => (LADSPA.Input or LADSPA.Control),
      Dry_Wet      => (LADSPA.Input or LADSPA.Control),
      Input        => (LADSPA.Input or LADSPA.Audio),
      Output       => (LADSPA.Output or LADSPA.Audio));

   Port_Names : constant Ports.Name_Array :=
     (Delay_Length => C.Strings.New_String ("Delay (Seconds)"),
      Dry_Wet      => C.Strings.New_String ("Dry/Wet Balance"),
      Input        => C.Strings.New_String ("Input"),
      Output       => C.Strings.New_String ("Output"));

   Port_Range_Hints : constant Ports.Range_Hint_Array :=
     (Delay_Length => (Hint_Descriptor => LADSPA.Bounded_Below or LADSPA.Bounded_Above or LADSPA.Default_1,
                       Lower_Bound     => 0.0,
                       Upper_Bound     => LADSPA.Data (Max_Delay)),
      Dry_Wet      => (Hint_Descriptor => LADSPA.Bounded_Below or LADSPA.Bounded_Above or LADSPA.Default_Middle,
                       Lower_Bound     => 0.0,
                       Upper_Bound     => 1.0),
      Input        => (Hint_Descriptor => LADSPA.Default_None,
                       others          => <>),
      Output       => (Hint_Descriptor => LADSPA.Default_None,
                       others          => <>));

   use type Interfaces.C.unsigned_long;

   --  This is required so that on finalisation of the library (unload), the globally allocated data is destroyed.
   type Descriptors is new LADSPA.Root_Descriptors with null record;

   overriding procedure Finalize (Self : in out Descriptors);

   Delay_Descriptor : constant Descriptors := (Ada.Finalization.Limited_Controlled with
      Data => (
        Unique_ID        => 1043,
        Label            => C.Strings.New_String ("delay_5s"),
        Properties       => LADSPA.Hard_RT_Capable,
        Name             => C.Strings.New_String ("Simple Delay Line"),
        Maker            => C.Strings.New_String ("Richard Furse (LADSPA example plugins) & Luke A. Guest (Ada port)"),
        Copyright        => C.Strings.New_String ("None"),
        Port_Count       => Port_Numbers'Pos (Port_Numbers'Last) + 1,  --  Pos starts at 0!
        Port_Descriptors => Port_Descriptors'Address,
        Port_Names       => Port_Names (Port_Names'First)'Access,
        Port_Range_Hints => Port_Range_Hints'Address,
        Instantiate      => Instantiate'Access,
        Connect_Port     => Connect_Port'Access,
        Activate         => Activate'Access,
        Run              => Run'Access,
        Clean_Up         => Clean_Up'Access,
        others           => <>
      ));

   function Descriptor (Index : C.unsigned_long) return access constant LADSPA.Descriptors with
     Export        => True,
     Convention    => C,
     External_Name => "ladspa_descriptor";
end Delays;