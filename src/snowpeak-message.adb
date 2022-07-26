--  ! WARNING: `snowpeak-message.adb` is generated by `pyexpander`.
--  ! Manually modifying this generated `.adb` file is strongly discouraged!

pragma Style_Checks ("N");

with Snowpeak.Compat; use Snowpeak.Compat;
with RFLX.RFC1157_SNMP.Message;
with RFLX.RFC1157_SNMP.Asn_Raw_SEQUENCE_OF_VarBind;
with RFLX.RFC1157_SNMP.VarBind;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with RFLX.RFLX_Types;
with System;


package body Snowpeak.Message is
   package Types renames RFLX.RFLX_Types;
   package Packet renames RFLX.RFC1157_SNMP.Message;
   package Varbind_Seq renames RFLX.RFC1157_SNMP.Asn_Raw_SEQUENCE_OF_VarBind;
   package Varbind_Packet renames RFLX.RFC1157_SNMP.Varbind;

   --  HACK: We assume here that the T and L fields in the TLV encoding are both of 1 byte.

   function I64_Length (I : I64) return Short_Length is
      J    : I64          := (if I < 0 then I + 1 else I);
      Bits : Short_Length := 1;
   begin
      loop
         J := J / 2;
         if J = 0 then
            return Bits / 8 + 1;
         end if;
         Bits := Bits + 1;
      end loop;
   end I64_Length;
   --  https://github.com/eerimoq/asn1tools/blob/44746200179038edc7d0895b03c5c0bb58285e43/asn1tools/codecs/ber.py#L253-L255

   function To_BE_Bytes (I : I64) return Types.Bytes is
      type BE_I64 is record
         Inner : I64;
      end record with
         Bit_Order            => System.High_Order_First,
         Scalar_Storage_Order => System.High_Order_First;

      for BE_I64 use record
         Inner at 0 range 0 .. 63;
      end record;

      subtype I64_Bytes is Types.Bytes (1 .. 8);
      function As_Bytes is new Ada.Unchecked_Conversion (BE_I64, I64_Bytes);

      Len : constant Short_Length := I64_Length (I);
   begin
      return As_Bytes ((Inner => I)) (Types.Index (8 - Len + 1) .. 8);
   end To_BE_Bytes;

   function Length (Self : TLV) return Short_Length is
     (Short_Length (if Self.Data = null then 0 else Self.Data.all'Length));

   function Length (Self : Varbind) return Short_Length is
     (Short_Length (Self.OID.Length) + Self.Variable.Length + 2 * 2);

   function Length (Self : PDU) return Short_Length is
      Res : Short_Length :=
        Short_Length
          (I64_Length (Self.Request_ID) + I64_Length (Self.Error_Status) +
           I64_Length (Self.Error_Index)) +
        4 * 2;
      --  + [for V of Self.Variable_Bindings.View => V.Length + 2]'Reduce("+", 0)
   begin
      --  HACK: Workaround for compiler internal error in version `23.0w-20220508`.
      for V of Self.Variable_Bindings.View loop
         Res := @ + V.Length + 2;
      end loop;
      return Res;
   end Length;

   function Length (Self : Message) return Short_Length is
     (I64_Length (Self.Version) + Short_Length (Self.Community.Length) +
      Self.Data.Length + 3 * 2);

   function Write (Item : Message) return Stream_Element_Array is
      Buffer : Types.Bytes_Ptr :=
        new Types.Bytes (1 .. Types.Index (Snowpeak.Max_UDP_Payload_Size));
      Context          : Packet.Context;
      Item_Full_Length : constant Stream_Element_Offset :=
        2 + Stream_Element_Offset (Item.Length);
      Res : Stream_Element_Array (1 .. Item_Full_Length);

      procedure Free is new Ada.Unchecked_Deallocation
        (Types.Bytes, Types.Bytes_Ptr);
   begin
      Packet.Initialize (Context, Buffer);


      Packet.Set_Tag_Class (Context, RFLX.Prelude.Asn_Tag_Class (0));
      Packet.Set_Tag_Form (Context, RFLX.Prelude.Asn_Tag_Form (1));
      Packet.Set_Tag_Num (Context, RFLX.Prelude.Asn_Tag_Num (16));
      Packet.Set_Untagged_Length (Context, RFLX.Prelude.Asn_Length (Item.Length));

      --  version: int
      Packet.Set_Untagged_Value_version_Tag_Class (Context, RFLX.Prelude.Asn_Tag_Class (0));
      Packet.Set_Untagged_Value_version_Tag_Form (Context, RFLX.Prelude.Asn_Tag_Form (0));
      Packet.Set_Untagged_Value_version_Tag_Num (Context, RFLX.Prelude.Asn_Tag_Num (2));
      Packet.Set_Untagged_Value_version_Untagged_Length (Context, RFLX.Prelude.Asn_Length (I64_Length (Item.Version)));
      Packet.Set_Untagged_Value_version_Untagged_Value (Context, To_BE_Bytes (Item.Version));

      --  community: Bytes
      Packet.Set_Untagged_Value_community_Tag_Class (Context, RFLX.Prelude.Asn_Tag_Class (0));
      Packet.Set_Untagged_Value_community_Tag_Form (Context, RFLX.Prelude.Asn_Tag_Form (0));
      Packet.Set_Untagged_Value_community_Tag_Num (Context, RFLX.Prelude.Asn_Tag_Num (4));
      Packet.Set_Untagged_Value_community_Untagged_Length (Context, RFLX.Prelude.Asn_Length (Item.Community.Length));
      Packet.Set_Untagged_Value_community_Untagged_Value (Context, Types.Bytes (Item.Community.View));

      Packet.Set_Untagged_Value_data_Tag_Class (Context, RFLX.Prelude.Asn_Tag_Class (Item.Data.Tag_Class));
      Packet.Set_Untagged_Value_data_Tag_Form (Context, RFLX.Prelude.Asn_Tag_Form (Item.Data.Tag_Form));
      Packet.Set_Untagged_Value_data_Tag_Num (Context, RFLX.Prelude.Asn_Tag_Num (Item.Data.Tag_Num));
      Packet.Set_Untagged_Value_data_get_response_Length (Context, RFLX.Prelude.Asn_Length (Item.Data.Length));

      --  data_get_response@request_id: int
      Packet.Set_Untagged_Value_data_get_response_Value_request_id_Tag_Class (Context, RFLX.Prelude.Asn_Tag_Class (0));
      Packet.Set_Untagged_Value_data_get_response_Value_request_id_Tag_Form (Context, RFLX.Prelude.Asn_Tag_Form (0));
      Packet.Set_Untagged_Value_data_get_response_Value_request_id_Tag_Num (Context, RFLX.Prelude.Asn_Tag_Num (2));
      Packet.Set_Untagged_Value_data_get_response_Value_request_id_Untagged_Length (Context, RFLX.Prelude.Asn_Length (I64_Length (Item.Data.Request_ID)));
      Packet.Set_Untagged_Value_data_get_response_Value_request_id_Untagged_Value (Context, To_BE_Bytes (Item.Data.Request_ID));

      --  data_get_response@error_status: int
      Packet.Set_Untagged_Value_data_get_response_Value_error_status_Tag_Class (Context, RFLX.Prelude.Asn_Tag_Class (0));
      Packet.Set_Untagged_Value_data_get_response_Value_error_status_Tag_Form (Context, RFLX.Prelude.Asn_Tag_Form (0));
      Packet.Set_Untagged_Value_data_get_response_Value_error_status_Tag_Num (Context, RFLX.Prelude.Asn_Tag_Num (2));
      Packet.Set_Untagged_Value_data_get_response_Value_error_status_Untagged_Length (Context, RFLX.Prelude.Asn_Length (I64_Length (Item.Data.Error_Status)));
      Packet.Set_Untagged_Value_data_get_response_Value_error_status_Untagged_Value (Context, To_BE_Bytes (Item.Data.Error_Status));

      --  data_get_response@error_index: int
      Packet.Set_Untagged_Value_data_get_response_Value_error_index_Tag_Class (Context, RFLX.Prelude.Asn_Tag_Class (0));
      Packet.Set_Untagged_Value_data_get_response_Value_error_index_Tag_Form (Context, RFLX.Prelude.Asn_Tag_Form (0));
      Packet.Set_Untagged_Value_data_get_response_Value_error_index_Tag_Num (Context, RFLX.Prelude.Asn_Tag_Num (2));
      Packet.Set_Untagged_Value_data_get_response_Value_error_index_Untagged_Length (Context, RFLX.Prelude.Asn_Length (I64_Length (Item.Data.Error_Index)));
      Packet.Set_Untagged_Value_data_get_response_Value_error_index_Untagged_Value (Context, To_BE_Bytes (Item.Data.Error_Index));

      --  data_get_response@variable_bindings: Seq<Varbind>
      Packet.Set_Untagged_Value_data_get_response_Value_variable_bindings_Tag_Class (Context, RFLX.Prelude.Asn_Tag_Class (0));
      Packet.Set_Untagged_Value_data_get_response_Value_variable_bindings_Tag_Form (Context, RFLX.Prelude.Asn_Tag_Form (1));
      Packet.Set_Untagged_Value_data_get_response_Value_variable_bindings_Tag_Num (Context, RFLX.Prelude.Asn_Tag_Num (16));
      Packet.Set_Untagged_Value_data_get_response_Value_variable_bindings_Untagged_Length (Context, RFLX.Prelude.Asn_Length ([for E of Item.Data.Variable_Bindings.View => E.Length + 2]'Reduce("+", Short_Length (0))));

      declare
         Varbind_Seq_Context : Varbind_Seq.Context;
         Varbind_Context : Varbind_Packet.Context;
      begin
         Packet.Switch_To_Untagged_Value_data_get_response_Value_variable_bindings_Untagged_Value
            (Context, Varbind_Seq_Context);

         for Element of Item.Data.Variable_Bindings.View loop
            Varbind_Seq.Switch (Varbind_Seq_Context, Varbind_Context);

            Varbind_Packet.Set_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (0));
            Varbind_Packet.Set_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (1));
            Varbind_Packet.Set_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (16));
            Varbind_Packet.Set_Untagged_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Length));

            Varbind_Packet.Set_Untagged_Value_name_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (0));
            Varbind_Packet.Set_Untagged_Value_name_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
            Varbind_Packet.Set_Untagged_Value_name_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (6));
            Varbind_Packet.Set_Untagged_Value_name_Untagged_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.OID.Length));
            Varbind_Packet.Set_Untagged_Value_name_Untagged_Value (Varbind_Context, Types.Bytes (Element.OID.View));

         --  Write `Element.Variable` to `Untagged_Value_value`.

            if Element.Variable.Tag_Class = 0 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 2 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (2));
               Varbind_Packet.Set_Untagged_Value_value_simple_number_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
               Varbind_Packet.Set_Untagged_Value_value_simple_number_Value (Varbind_Context, Element.Variable.Data.all);
            elsif Element.Variable.Tag_Class = 0 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 4 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (4));
               Varbind_Packet.Set_Untagged_Value_value_simple_string_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
               Varbind_Packet.Set_Untagged_Value_value_simple_string_Value (Varbind_Context, Element.Variable.Data.all);
            elsif Element.Variable.Tag_Class = 0 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 5 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (5));
               Varbind_Packet.Set_Untagged_Value_value_simple_empty_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
            elsif Element.Variable.Tag_Class = 0 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 6 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (6));
               Varbind_Packet.Set_Untagged_Value_value_simple_object_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
               Varbind_Packet.Set_Untagged_Value_value_simple_object_Value (Varbind_Context, Element.Variable.Data.all);
            elsif Element.Variable.Tag_Class = 1 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 0 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (1));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (0));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_address_internet_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_address_internet_Value (Varbind_Context, Element.Variable.Data.all);
            elsif Element.Variable.Tag_Class = 1 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 1 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (1));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (1));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_counter_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_counter_Value (Varbind_Context, Element.Variable.Data.all);
            elsif Element.Variable.Tag_Class = 1 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 2 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (1));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (2));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_gauge_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_gauge_Value (Varbind_Context, Element.Variable.Data.all);
            elsif Element.Variable.Tag_Class = 1 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 3 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (1));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (3));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_ticks_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_ticks_Value (Varbind_Context, Element.Variable.Data.all);
            elsif Element.Variable.Tag_Class = 1 and then Element.Variable.Tag_Form = 0 and then Element.Variable.Tag_Num = 4 then
               Varbind_Packet.Set_Untagged_Value_value_Tag_Class (Varbind_Context, RFLX.Prelude.Asn_Tag_Class (1));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Form (Varbind_Context, RFLX.Prelude.Asn_Tag_Form (0));
               Varbind_Packet.Set_Untagged_Value_value_Tag_Num (Varbind_Context, RFLX.Prelude.Asn_Tag_Num (4));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_arbitrary_Length (Varbind_Context, RFLX.Prelude.Asn_Length (Element.Variable.Length));
               Varbind_Packet.Set_Untagged_Value_value_application_wide_arbitrary_Value (Varbind_Context, Element.Variable.Data.all);
            else raise Constraint_Error with "Unsupported ASN.1 tag found"; end if;

            Varbind_Seq.Update (Varbind_Seq_Context, Varbind_Context);
         end loop;
         
         Packet.Update_Untagged_Value_data_get_response_Value_variable_bindings_Untagged_Value
            (Context, Varbind_Seq_Context);
      end;

      Packet.Verify_Message (Context);
      pragma Assert (Packet.Structural_Valid_Message (Context));
      
      Packet.Take_Buffer (Context, Buffer);
      Res := To_Ada_Stream (Buffer.all) (1 .. Item_Full_Length);
      Free (Buffer);
      return Res;
   end Write;
   --  https://stackoverflow.com/a/22770989

   function From_BE_Bytes (Raw : Types.Bytes) return I64 is
      First : constant Types.Byte := Raw (Raw'First);
      Res   : I64                 := I64 (First mod 2**7);
      Pos   : constant Boolean    := First / (2**7) = 0;
   begin
      for I in Raw'First + 1 .. Raw'Last loop
         Res := @ * (2**8) + I64 (Raw (I));
      end loop;
      return (if Pos then Res else Res - 2**(8 * Raw'Length - 1));
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

         --  data_get_request@variable_bindings: Seq<Varbind>
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
                     for C of Buffer loop Element.OID.Push (C); end loop;
                  end;

                  Res.Data.Variable_Bindings.Push (Element);
                  Varbind_Seq.Update (Varbind_Seq_Context, Varbind_Context);
               end;
            end loop;
            
            Packet.Update_Untagged_Value_data_get_request_Value_variable_bindings_Untagged_Value
               (Context, Varbind_Seq_Context);
         end;
         return Res;
      end;
   end Read;
end Snowpeak.Message;
