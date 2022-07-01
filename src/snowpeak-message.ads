with Ada.Containers.Vectors; use Ada.Containers;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Snowpeak.Message is
   package Integers is new Vectors (Natural, Integer);

   type Varbind is record
      OID      : Integers.Vector;
      Variable : Unbounded_String;
      --  HACK: Ideally there should be a huge sum type as in https://docs.rs/snmp-parser/0.8.0/snmp_parser/snmp/enum.ObjectSyntax.html
   end record;
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/pdu.go#L12-L15

   package Varbinds is new Vectors (Natural, Varbind);

   type PDU is record
      Request_ID        : Integer;
      Error_Status      : Integer := 0; --  noError(0)
      Error_Index       : Integer := 0;
      Variable_Bindings : Varbinds.Vector;
   end record;
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/pdu.go#L188-L194

   type Message is record
      Version   : Integer := 0; --  version-1(0)
      Community : Unbounded_String;
      Data      : PDU; --  TODO: Add support for Trap_PDU.
   end record;
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/message.go#L20-L25

   type Message_Access is access Message;

   function Write (Item : Message) return Stream_Element_Array;

   function Read
     (Buffer : Stream_Element_Array; Last : Stream_Element_Offset)
      return Message;
end Snowpeak.Message;
