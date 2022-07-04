with Snowpeak.Compat; use Snowpeak.Compat;
with RFLX.RFC1157_SNMP.Message;
with RFLX.RFLX_Types;
with RFLX.RFLX_Builtin_Types; use RFLX.RFLX_Builtin_Types;

package body Snowpeak.Message is
   package Types renames RFLX.RFLX_Types;
   package Packet renames RFLX.RFC1157_SNMP.Message;

   -- function Write (Item : Message) return Stream_Element_Array
   -- is
   --    Buffer : Types.Bytes_Ptr :=
   --      new Types.Bytes (1 .. Types.Index (Snowpeak.Max_UDP_Payload_Size));
   --       Context : Packet.Context;
   --    Res : Stream_Element_Array
   --       (1 .. Stream_Element_Offset (Snowpeak.Max_UDP_Payload_Size));

   --    procedure Free is new Ada.Unchecked_Deallocation
   --      (Types.Bytes, Types.Bytes_Ptr);
   -- begin
   --    Packet.Initialize (Context, Buffer);

   --    Packet.Set_Size (Context, Str_Size (Item.Size));
   --    if Item.Size /= 0 then
   --       Packet.Set_Str (Context, [for C of Item.Str => Character'Pos (C)]);
   --    end if;

   --    Packet.Take_Buffer (Context, Buffer);
   --    Res := To_Ada_Stream (Buffer.all);
   --    Free (Buffer);
   --    return Res;
   -- end Write;
   -- --  https://stackoverflow.com/a/22770989

   function From_BE_Bytes (Raw : Types.Bytes) return I64 is
      Res : I64 := I64 (Raw (Raw'First));
   begin
      for I in Raw'First + 1 .. Raw'Last loop
         Res := @ * (2 ** 8) + I64 (Raw (I));
      end loop;
      return Res;
   end From_BE_Bytes;

   function Read
     (Buffer : Stream_Element_Array; Last : Stream_Element_Offset)
      return Message
   is
      Context : Packet.Context;
   begin
      declare
         Bytes_Buffer : Types.Bytes_Ptr := new Types.Bytes'(To_RFLX_Bytes
            (Buffer (1 .. Last)));
         Size : constant Integer :=  Integer (Bytes_Buffer.all (2));

         Res : Message;
      begin
         pragma Assert (Size < 128);
         --  ... so that it's actually a 7-bit length.
         Packet.Initialize (Context, Bytes_Buffer,
            Written_Last => 8 * 2 + Bit_Length (8 * Size));
         Packet.Verify_Message (Context);
         pragma Assert (Packet.Structural_Valid_Message (Context));
         --  TODO: Add some error handling.

         --  version: int
         declare
            Size : constant Types.Bit_Length := Packet.Field_Size
               (Context, Packet.F_Untagged_Value_version_Untagged_Value);
            Buffer : Types.Bytes (1 .. Types.To_Index (Size + 1));
         begin
            Packet.Get_Untagged_Value_version_Untagged_Value (Context, Buffer);
            Res.Version := From_BE_Bytes (Buffer);
         end;

         --  community: Bytes
         declare
            Size : constant Types.Bit_Length := Packet.Field_Size
               (Context, Packet.F_Untagged_Value_community_Untagged_Value);
            Buffer : Types.Bytes (1 .. Types.To_Index (Size + 1));
         begin
            Packet.Get_Untagged_Value_community_Untagged_Value
               (Context, Buffer);
            Res.Community := To_Unbounded_String
               ([for C of Buffer => Character'Val (C)]);
         end;

         --  TODO: Add more fields.

         return Res;
      end;
   end Read;
end Snowpeak.Message;
