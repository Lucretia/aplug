with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;
with System;

package LADSPA is
   pragma Preelaborate;

   Version       : aliased constant String := "1.1";
   Version_Major : constant := 1;
   Version_Minor : constant := 1;

   subtype Data is C_float;  --  /usr/include/ladspa.h:84

   type Data_Ptr is access all Data with
     Convention => C;

   type Data_Array is array (unsigned_long range <>) of aliased Data with
     Convention => C;

   --  As defined in C, this is an int, which is signed! In Ada, it must be unsigned.
   type All_Properties is mod 2 ** int'Size with  --  /usr/include/ladspa.h:94
     Convention => C;

   --  See ladspa.h for description of each.
   Real_Time       : constant All_Properties := 1;
   In_Place_Broken : constant All_Properties := 2;
   Hard_RT_Capable : constant All_Properties := 4;

   --  arg-macro: function LADSPA_IS_REALTIME (x)
   --    return (x) and LADSPA_PROPERTY_REALTIME;
   --  arg-macro: function LADSPA_IS_INPLACE_BROKEN (x)
   --    return (x) and LADSPA_PROPERTY_INPLACE_BROKEN;
   --  arg-macro: function LADSPA_IS_HARD_RT_CAPABLE (x)
   --    return (x) and LADSPA_PROPERTY_HARD_RT_CAPABLE;

   --  As above, re All_Properties.
   type All_Port_Descriptors is mod 2 ** int'Size with  --  /usr/include/ladspa.h:152
     Convention => C;

   --  See ladspa.h for description of each.
   Input   : constant All_Port_Descriptors := 1;
   Output  : constant All_Port_Descriptors := 2;
   Control : constant All_Port_Descriptors := 4;
   Audio   : constant All_Port_Descriptors := 8;

   --  arg-macro: function LADSPA_IS_PORT_INPUT (x)
   --    return (x) and LADSPA_PORT_INPUT;
   --  arg-macro: function LADSPA_IS_PORT_OUTPUT (x)
   --    return (x) and LADSPA_PORT_OUTPUT;
   --  arg-macro: function LADSPA_IS_PORT_CONTROL (x)
   --    return (x) and LADSPA_PORT_CONTROL;
   --  arg-macro: function LADSPA_IS_PORT_AUDIO (x)
   --    return (x) and LADSPA_PORT_AUDIO;

   --  As above, re All_Properties.
   type Port_Range_Hint_Descriptors is mod 2 ** int'Size with  --  /usr/include/ladspa.h:200
     Convention => C;

   --  See ladspa.h for description of each.
   Bounded_Below   : constant Port_Range_Hint_Descriptors := 16#1#;
   Bounded_Above   : constant Port_Range_Hint_Descriptors := 16#2#;
   Toggled         : constant Port_Range_Hint_Descriptors := 16#4#;
   Sample_Rate     : constant Port_Range_Hint_Descriptors := 16#8#;
   Logarithmic     : constant Port_Range_Hint_Descriptors := 16#10#;
   Integer         : constant Port_Range_Hint_Descriptors := 16#20#;  --  Is "Integer" in C, which is a keyword in Ada.
   Default_Mask    : constant Port_Range_Hint_Descriptors := 16#3C0#;
   Default_None    : constant Port_Range_Hint_Descriptors := 16#0#;
   Default_Minimum : constant Port_Range_Hint_Descriptors := 16#40#;
   Default_Low     : constant Port_Range_Hint_Descriptors := 16#80#;
   Default_Middle  : constant Port_Range_Hint_Descriptors := 16#C0#;
   Default_High    : constant Port_Range_Hint_Descriptors := 16#100#;
   Default_Maximum : constant Port_Range_Hint_Descriptors := 16#140#;
   Default_0       : constant Port_Range_Hint_Descriptors := 16#200#;
   Default_1       : constant Port_Range_Hint_Descriptors := 16#240#;
   Default_100     : constant Port_Range_Hint_Descriptors := 16#280#;
   Default_440     : constant Port_Range_Hint_Descriptors := 16#2C0#;
   --  arg-macro: function LADSPA_IS_HINT_BOUNDED_BELOW (x)
   --    return (x) and LADSPA_HINT_BOUNDED_BELOW;
   --  arg-macro: function LADSPA_IS_HINT_BOUNDED_ABOVE (x)
   --    return (x) and LADSPA_HINT_BOUNDED_ABOVE;
   --  arg-macro: function LADSPA_IS_HINT_TOGGLED (x)
   --    return (x) and LADSPA_HINT_TOGGLED;
   --  arg-macro: function LADSPA_IS_HINT_SAMPLE_RATE (x)
   --    return (x) and LADSPA_HINT_SAMPLE_RATE;
   --  arg-macro: function LADSPA_IS_HINT_LOGARITHMIC (x)
   --    return (x) and LADSPA_HINT_LOGARITHMIC;
   --  arg-macro: function LADSPA_IS_HINT_INTEGER (x)
   --    return (x) and LADSPA_HINT_INTEGER;
   --  arg-macro: function LADSPA_IS_HINT_HAS_DEFAULT (x)
   --    return (x) and LADSPA_HINT_DEFAULT_MASK;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_MINIMUM (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_MINIMUM;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_LOW (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_LOW;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_MIDDLE (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_MIDDLE;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_HIGH (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_HIGH;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_MAXIMUM (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_MAXIMUM;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_0 (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_0;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_1 (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_1;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_100 (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_100;
   --  arg-macro: function LADSPA_IS_HINT_DEFAULT_440 (x)
   --    return ((x) and LADSPA_HINT_DEFAULT_MASK) = LADSPA_HINT_DEFAULT_440;

   type All_Port_Range_Hints is
      record
         Hint_Descriptor : aliased Port_Range_Hint_Descriptors;
         Lower_Bound     : aliased Data;
         Upper_Bound     : aliased Data;
      end record with
        Convention => C_Pass_By_Copy;

   --  Helper package.
   --  TODO: There's got to be a better name for this!
   generic
      type Port_Type is (<>);
   package Port_Information is
      type Descriptor_Array is array (Port_Type) of LADSPA.All_Port_Descriptors with
        Convention => C;

      type Name_Array is array (Port_Type) of aliased Interfaces.C.Strings.chars_ptr with
        Convention => C;

      type Range_Hint_Array is array (Port_Type) of LADSPA.All_Port_Range_Hints with
        Convention => C;
   end Port_Information;

   type Base_Handle is null record with  --  /usr/include/ladspa.h:363
     Convention => C;

   type Handles is access all Base_Handle with
     Convention => C;

   type Descriptors;

   type Instantiators is access function (Descriptor  : access constant Descriptors;
                                          Sample_Rate : unsigned_long) return Handles with
     Convention => C;

   type Port_Connectors is access procedure (Instance      : in Handles;
                                             Port          : in unsigned_long;
                                             Data_Location : in Data_Ptr) with
     Convention => C;

   type Activators is access procedure (Instance : in Handles) with
     Convention => C;

   type Deactivators is access procedure (Instance : in Handles) with
     Convention => C;

   type Runners is access procedure (Instance : in Handles; Sample_Count : in unsigned_long) with
     Convention => C;

   --  type Adding_Runners is access procedure (Instance : in out Handles; Sample_Count : in unsigned_long) with
   --    Convention => C;

   type Gain_Adding_Runners is access procedure (Instance : in Handles; Gain : in Data) with
     Convention => C;

   type Cleaners is access procedure (Instance : in Handles) with
     Convention => C;

   type Port_Name_Array_Ptr is not null access constant Interfaces.C.Strings.chars_ptr;

   type Descriptors is record
      Unique_ID            : aliased unsigned_long;
      Label                : Interfaces.C.Strings.chars_ptr;
      Properties           : aliased All_Properties;
      Name                 : Interfaces.C.Strings.chars_ptr;
      Maker                : Interfaces.C.Strings.chars_ptr;
      Copyright            : Interfaces.C.Strings.chars_ptr;
      Port_Count           : aliased unsigned_long;
      Port_Descriptors     : System.Address;  --  access All_Port_Descriptors;
      Port_Names           : Port_Name_Array_Ptr;
      Port_Range_Hints     : System.Address;  --  access constant All_Port_Range_Hints;
      Implementation_Data  : System.Address;
      Instantiate          : Instantiators;
      Connect_Port         : Port_Connectors;
      Activate             : Activators;
      Run                  : Runners;
      Run_Adding           : Runners;
      Set_Run_Adding_Gain  : Gain_Adding_Runners;
      Deactivate           : Deactivators;
      Clean_Up             : Cleaners;
   end record with
     Convention => C_Pass_By_Copy;

   type Descriptor_Functions is access function (Index : unsigned_long) return access constant Descriptors with
     Convention => C;  --  /usr/include/ladspa.h:593
end LADSPA;
