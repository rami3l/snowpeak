package Snowpeak is
   Max_UDP_Payload_Size : constant Integer := 576 - 60 - 8;
   --  See: https://stackoverflow.com/a/35697810
end Snowpeak;
