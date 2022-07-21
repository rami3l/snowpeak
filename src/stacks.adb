package body Stacks is
   function Length (Self : Stack) return Natural is
     (Self.Top + 1 - Self.Container'First);
   function View (Self : Stack) return Stack_Array is
     (Self.Container (Min .. Self.Top));
   function Is_Empty (Self : Stack) return Boolean is
     (Self.Top < Self.Container'First);
   overriding function "=" (Self, Other : Stack) return Boolean is
     (Self.View = Other.View);
   function Is_Full (Self : Stack) return Boolean is
     (Self.Top >= Self.Container'Last);

   function Pop (Self : in out Stack) return T is
   begin
      if Is_Empty (Self) then
         raise Stack_Underflow;
      else
         return X : T do
            X        := Self.Container (Self.Top);
            Self.Top := Self.Top - 1;
         end return;
      end if;
   end Pop;

   procedure Push (Self : in out Stack; V : T) is
   begin
      if Is_Full (Self) then
         raise Stack_Overflow;
      else
         Self.Top                  := Self.Top + 1;
         Self.Container (Self.Top) := V;
      end if;
   end Push;

   procedure Put_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Arg    :        Stack)
   is
   begin
      Buffer.Put (Arg.View'Image);
   end Put_Image;
end Stacks;
