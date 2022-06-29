with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;
with Snowpeak.Listener;

package body Snowpeak is
   procedure Snowpeak is
      Agent_Addr : constant Sock_Addr_Type :=
        (Addr => Inet_Addr ("127.0.0.1"), Port => 161, others => <>);
      Listener : Snowpeak.Listener.Listener;
   begin
      Snowpeak.Listener.Bind (Addr, Listener);

      loop
         Receive_Socket (Listener.Channel, Buffer, Last, From => Peer_Addr);
         declare
            Got : constant Message := Read (Buffer, Last);
         begin
            Put_Line ("Pong Received: " & Got.Str);
            Send_Socket (Listener.Channel, Write (Got), Last, To => Peer_Addr);
            exit when Got.Str = "";
         end;
      end loop;
   end Snowpeak;
end Snowpeak;
