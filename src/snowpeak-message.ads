with Ada.Streams; use Ada.Streams;

package Snowpeak.Message is
   subtype Message_Size_Type is Integer range 0 .. 255;

   type Message (Size : Message_Size_Type) is record
      Str : String (1 .. Size);
   end record;

   type Message_Access is access Message;

   function To_Message (Str : String) return Message with
      Pre => Str'Length in Message_Size_Type;

   function Write (Item : Message) return Stream_Element_Array;

   function Read
     (Buffer : Stream_Element_Array; Last : Stream_Element_Offset)
      return Message;
end Snowpeak.Message;
