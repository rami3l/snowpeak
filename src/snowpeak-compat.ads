-- SRC: https://github.com/Componolit/RecordFlux/blob/5dd82231eec29a98a25fe67153a3bd03ccd5d3d0/examples/apps/dhcp_client/src/channel.ads

with Ada.Streams; use Ada.Streams;
with RFLX.RFLX_Builtin_Types;

package Snowpeak.Compat with
   SPARK_Mode
is
   use type RFLX.RFLX_Builtin_Types.Index;

   function To_Ada_Stream
     (Buffer : RFLX.RFLX_Builtin_Types.Bytes) return Stream_Element_Array with
      Pre => Buffer'First = 1
      and then Buffer'Length <= Stream_Element_Offset'Last;

   function To_RFLX_Bytes
     (Buffer : Stream_Element_Array) return RFLX.RFLX_Builtin_Types.Bytes with
      Pre => Buffer'First = 1
      and then Buffer'Length <=
        Stream_Element_Offset (RFLX.RFLX_Builtin_Types.Index'Last);
end Snowpeak.Compat;
