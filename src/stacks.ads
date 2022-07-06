generic
   Max : Positive;
   type T is private;
package Stacks is
   type Stack is tagged private;

   Stack_Underflow, Stack_Overflow : exception;
   function Is_Empty (Self : Stack) return Boolean;
   function Pop (Self : in out Stack) return T;
   procedure Push (Self : in out Stack; V : T);
private
   type Stack_Array is array (Natural range <>) of T;

   Min : constant := 1;

   type Stack is tagged record
      Container : Stack_Array (Min .. Max);
      Top       : Natural := Min - 1;
   end record;
end Stacks;
--  https://learn.adacore.com/courses/intro-to-ada/chapters/generics.html#example-adts
