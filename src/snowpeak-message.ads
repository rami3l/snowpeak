with Ada.Streams;             use Ada.Streams;
with RFLX.Prelude;            use RFLX.Prelude;
with RFLX.RFLX_Builtin_Types; use RFLX.RFLX_Builtin_Types;
with Stacks;

package Snowpeak.Message is
   package Prelude renames RFLX.Prelude;
   package Bytes is new Stacks (32, Byte);

   type Short_Length is mod 2**7;
   type I64 is range -(2**63) .. (2**63 - 1);

   function I64_Length (I : I64) return Short_Length;

   type TLV is tagged record
      Tag_Class : Prelude.Asn_Tag_Class := 0;
      Tag_Form  : Prelude.Asn_Tag_Form  := 0;
      Tag_Num   : Prelude.Asn_Tag_Num   := 5;
      Data      : Bytes_Ptr;
   end record;
   --  TLV represents an SNMP variable encoded with ASN.1 BER.

   function Length (Self : TLV) return Short_Length;

   type Varbind is tagged record
      OID      : Bytes.Stack;
      Variable : TLV;
      --  HACK: Now we assume that this field contains the V field of `Variable`'s
      --  ASN.1 BER encoding. (This influences the implementation of the `Length` method.)
      --  However, it seems necessary to include the T field as well.
      --  Ideally there should be a huge sum type as in https://docs.rs/snmp-parser/0.8.0/snmp_parser/snmp/enum.ObjectSyntax.html
   end record;
   --  Varbind represents an SNMP variable binding.
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/pdu.go#L12-L15

   function Length (Self : Varbind) return Short_Length;

   package Varbinds is new Stacks (32, Varbind);

   type PDU is tagged record
      Tag_Class         : Prelude.Asn_Tag_Class := 2; --  Context(2)
      Tag_Form          : Prelude.Asn_Tag_Form  := 1; --  Constructed(1)
      Tag_Num           : Prelude.Asn_Tag_Num   := 2; --  GetResponse(2)
      Request_ID        : I64;
      Error_Status      : I64                   := 0; --  noError(0)
      Error_Index       : I64                   := 0;
      Variable_Bindings : Varbinds.Stack;
   end record;
   --  PDU represents an SNMP PDU (except Trap-PDU).
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/pdu.go#L188-L194

   function Length (Self : PDU) return Short_Length;

   type Message is tagged record
      Version   : I64 := 0; --  version-1(0)
      Community : Bytes.Stack;
      Data      : PDU; --  TODO: Add support for Trap_PDU.
   end record;
   --  Message represents an SNMP packet.
   --  https://github.com/k-sone/snmpgo/blob/de09377ff34857b08afdc16ea8c7c2929eb1fc6e/message.go#L20-L25

   function Length (Self : Message) return Short_Length;
   --  Returns the length of the ASN.1 BER encoding of this Message.

   type Message_Access is access Message;

   function Write (Item : Message) return Stream_Element_Array;
   --  Encodes this Message with ASN.1 BER.

   function Read
     (Buffer : Stream_Element_Array; Last : Stream_Element_Offset)
      return Message;
   --  Decodes a Message from ASN.1 BER bytes in the given Buffer.
end Snowpeak.Message;
