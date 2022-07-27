with Options;
with Snowpeak.Message;
with RFLX.RFLX_Types;

package Snowpeak.Querier is
   package Varbind_Options is new Options (Snowpeak.Message.Varbind);

   type Querier is interface;

   function Get_TLV
     (Self : Querier; OID : RFLX.RFLX_Types.Bytes)
      return Varbind_Options.Option is abstract;

   function Get_Next_TLV
     (Self : Querier; OID : RFLX.RFLX_Types.Bytes)
      return Varbind_Options.Option is abstract;

   function Respond
     (Self : Querier'Class; Request : Snowpeak.Message.Message)
      return Snowpeak.Message.Message;

   type Map_Querier is new Querier with record
      Data : Snowpeak.Message.Varbinds.Stack; -- An ORDERED list of Varbinds.
   end record;

   overriding function Get_TLV
     (Self : Map_Querier; OID : RFLX.RFLX_Types.Bytes)
      return Varbind_Options.Option;

   overriding function Get_Next_TLV
     (Self : Map_Querier; OID : RFLX.RFLX_Types.Bytes)
      return Varbind_Options.Option;
end Snowpeak.Querier;
