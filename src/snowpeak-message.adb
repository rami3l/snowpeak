pragma Style_Checks ("N");

with Snowpeak.Compat; use Snowpeak.Compat;
with RFLX.RFC1157_SNMP.Message;
with RFLX.RFC1157_SNMP.Asn_Raw_SEQUENCE_OF_VarBind;
with RFLX.RFC1157_SNMP.VarBind;
with RFLX.RFLX_Types;

package body Snowpeak.Message is
   package Types renames RFLX.RFLX_Types;
   package Packet renames RFLX.RFC1157_SNMP.Message;
   package Varbind_Seq renames RFLX.RFC1157_SNMP.Asn_Raw_SEQUENCE_OF_VarBind;
   package Varbind_Packet renames RFLX.RFC1157_SNMP.Varbind;

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
      Res : Message;
   begin
      declare
         Bytes_Buffer : Types.Bytes_Ptr := new Types.Bytes'(To_RFLX_Bytes
            (Buffer (1 .. Last)));
         Size : constant Integer :=  Integer (Bytes_Buffer.all (2));
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
            Buffer : Types.Bytes (1 .. Types.To_Index (Size));
         begin
            Packet.Get_Untagged_Value_version_Untagged_Value (Context, Buffer);
            Res.Version := From_BE_Bytes (Buffer);
         end;

         --  community: Bytes
         declare
            Size : constant Types.Bit_Length := Packet.Field_Size
               (Context, Packet.F_Untagged_Value_community_Untagged_Value);
            Buffer : Types.Bytes (1 .. Types.To_Index (Size));
         begin
            Packet.Get_Untagged_Value_community_Untagged_Value (Context, Buffer);
            for C of Buffer loop Res.Community.Push (C); end loop;
         end;

         --  TODO: Support get-next-request?

         --  data_get_request@request_id: int
         declare
            Size : constant Types.Bit_Length := Packet.Field_Size
               (Context, Packet.F_Untagged_Value_data_get_request_Value_request_id_Untagged_Value);
            Buffer : Types.Bytes (1 .. Types.To_Index (Size));
         begin
            Packet.Get_Untagged_Value_data_get_request_Value_request_id_Untagged_Value (Context, Buffer);
            Res.Data.Request_ID := From_BE_Bytes (Buffer);
         end;

         --  data_get_request@error_status: int
         declare
            Size : constant Types.Bit_Length := Packet.Field_Size
               (Context, Packet.F_Untagged_Value_data_get_request_Value_error_status_Untagged_Value);
            Buffer : Types.Bytes (1 .. Types.To_Index (Size));
         begin
            Packet.Get_Untagged_Value_data_get_request_Value_error_status_Untagged_Value (Context, Buffer);
            Res.Data.Error_Status := From_BE_Bytes (Buffer);
         end;

         --  data_get_request@error_index: int
         declare
            Size : constant Types.Bit_Length := Packet.Field_Size
               (Context, Packet.F_Untagged_Value_data_get_request_Value_error_index_Untagged_Value);
            Buffer : Types.Bytes (1 .. Types.To_Index (Size));
         begin
            Packet.Get_Untagged_Value_data_get_request_Value_error_index_Untagged_Value (Context, Buffer);
            Res.Data.Error_Index := From_BE_Bytes (Buffer);
         end;

         --  TODO: Add Varbinds
         declare
            Varbind_Seq_Context : Varbind_Seq.Context;
            Varbind_Context : Varbind_Packet.Context;
         begin
            Packet.Switch_To_Untagged_Value_data_get_request_Value_variable_bindings_Untagged_Value
               (Context, Varbind_Seq_Context);
            while Varbind_Seq.Has_Element (Varbind_Seq_Context) loop
               declare
                  Element : Varbind;
               begin
                  Varbind_Seq.Switch (Varbind_Seq_Context, Varbind_Context);
                  Varbind_Packet.Verify_Message (Varbind_Context);

                  declare
                     Size : constant Types.Bit_Length := Varbind_Packet.Field_Size
                        (Varbind_Context, Varbind_Packet.F_Untagged_Value_name_Untagged_Value);
                     Buffer : Types.Bytes (1 .. Types.To_Index (Size));
                  begin
                     Varbind_Packet.Get_Untagged_Value_name_Untagged_Value (Varbind_Context, Buffer);
                     for C of Buffer loop Element.OID.Push (Integer (C)); end loop;
                  end;

                  Res.Data.Variable_Bindings.Push (Element);
                  Varbind_Seq.Update (Varbind_Seq_Context, Varbind_Context);
               end;
            end loop;
         end;
         return Res;
      end;
   end Read;
end Snowpeak.Message;
