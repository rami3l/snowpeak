with Ada.Streams; use Ada.Streams;

package Snowpeak is
   Max_UDP_Payload_Size : constant Stream_Element_Offset := 576 - 60 - 8;
   --  See: https://stackoverflow.com/a/35697810
end Snowpeak;
