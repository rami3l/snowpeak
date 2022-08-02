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
   --  Option represents an value that might or might not be present according to the `Valid` flag.
   --  https://doc.rust-lang.org/std/option/enum.Option.html
end Options;
