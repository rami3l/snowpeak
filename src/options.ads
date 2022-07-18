generic
   type T is private;
package Options is
   type Option (Valid : Boolean := False) is record
      case Valid is
         when True =>
            Value : T;
         when False =>
            null;
      end case;
   end record;
end Options;
