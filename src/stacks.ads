with Ada.Strings.Text_Buffers;

generic
   Max : Positive;
   type T is private;
package Stacks is
   type Stack is tagged private;
   type Stack_Array is array (Natural range <>) of T;

   Stack_Underflow, Stack_Overflow : exception;
   function Length (Self : Stack) return Natural;
   function View (Self : Stack) return Stack_Array;
   function Is_Empty (Self : Stack) return Boolean;
   function Pop (Self : in out Stack) return T;
   procedure Push (Self : in out Stack; V : T);
private

   Min : constant := 1;

   type Stack is tagged record
      Container : Stack_Array (Min .. Max);
      Top       : Natural := Min - 1;
   end record with
      Put_Image => Put_Image;
      --  http://www.ada-auth.org/standards/2xrm/html/RM-4-10.html

   procedure Put_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Arg    :        Stack);
end Stacks;
--  https://learn.adacore.com/courses/intro-to-ada/chapters/generics.html#example-adts
