with Ada.Streams;             use Ada.Streams;
with RFLX.RFLX_Builtin_Types; use RFLX.RFLX_Builtin_Types;
with Stacks;

package Snowpeak.Message is
   package Integers is new Stacks (32, Integer);
   package Bytes is new Stacks (32, Byte);

   type Short_Length is mod 2**7;
   type I64 is range -(2**63) .. (2**63 - 1);

   function I64_Length (I : I64) return Short_Length;

   type Varbind is tagged record
      OID      : Integers.Stack;
      Variable : Bytes.Stack;
      --  HACK: Ideally there should be a huge sum type as in https://docs.rs/snmp-parser/0.8.0/snmp_parser/snmp/enum.ObjectSyntax.html
   end record;
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/pdu.go#L12-L15

   function Length (Self : Varbind) return Short_Length;

   package Varbinds is new Stacks (32, Varbind);

   type PDU is tagged record
      Request_ID        : I64;
      Error_Status      : I64 := 0; --  noError(0)
      Error_Index       : I64 := 0;
      Variable_Bindings : Varbinds.Stack;
   end record;
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/pdu.go#L188-L194

   function Length (Self : PDU) return Short_Length;

   type Message is tagged record
      Version   : I64 := 0; --  version-1(0)
      Community : Bytes.Stack;
      Data      : PDU; --  TODO: Add support for Trap_PDU.
   end record;
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/message.go#L20-L25

   function Length (Self : Message) return Short_Length;

   type Message_Access is access Message;

   -- function Write (Item : Message) return Stream_Element_Array;

   function Read
     (Buffer : Stream_Element_Array; Last : Stream_Element_Offset)
      return Message;
end Snowpeak.Message;
