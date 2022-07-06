package body Stacks is
   function Is_Empty (Self : Stack) return Boolean is
     (Self.Top < Self.Container'First);
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
end Stacks;
