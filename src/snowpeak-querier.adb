with RFLX.RFLX_Builtin_Types; use RFLX.RFLX_Builtin_Types;

package body Snowpeak.Querier is
   function Respond
     (Self : Querier'Class; Request : Message.Message) return Message.Message
   is
      Varbinds : Message.Varbinds.Stack;
      Ans : TLV_Options.Option;
      Res : Message.Message;
      View : constant Message.Varbinds.Stack_Array :=
         Request.Data.Variable_Bindings.View;
   begin
      for I in View'First .. View'Last loop
         Ans := Self.Get_TLV (Bytes (View (I).OID.View));
         if not Ans.Valid then
            Res := (Request with delta Data => (Request.Data with delta
               Error_Status => 2, --  noSuchname
               Error_Index => Message.I64 (I)));
            exit;
         end if;
         Varbinds.Push ((OID => View (I).OID, Variable => Ans.Value));
      end loop;
      if Integer (Res.Data.Error_Status) /= 2 then --  noSuchName
         Res := (Request with delta Data => (Request.Data with delta
            Variable_Bindings => Varbinds));
      end if;
      --  This case currently won't happen due to small `Res.Length` range.
      --  if Integer (Res.Length) + 2 > Max_UDP_Payload_Size then
      --     Res := (Request with delta Data =>
      --       (Request.Data with delta Error_Status => 1)); --  tooBig
      --  end if;
      Res.Data.Tag_Num := 2; --  GetResponse
      return Res;
   end Respond;

   overriding function Get_TLV
     (Self : Map_Querier; OID : RFLX.RFLX_Types.Bytes)
      return TLV_Options.Option
   is
      Res : TLV_Options.Option;
   begin
      for V of Self.Data.View loop
         if OID = Bytes (V.OID.View) then
            return (Valid => True, Value => V.Variable);
         end if;
      end loop;
      return Res;
   end Get_TLV;
end Snowpeak.Querier;
