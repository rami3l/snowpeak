with Ada.Streams;      use Ada.Streams;
with Ada.Text_IO;      use Ada.Text_IO;
with GNAT.Sockets;     use GNAT.Sockets;
with Snowpeak.Listener;
with Snowpeak.Message; use Snowpeak.Message;
with Snowpeak;

procedure Main is
   Agent_Addr : constant Sock_Addr_Type :=
     (Addr => Inet_Addr ("127.0.0.1"), Port => 161, others => <>);
   Peer_Addr : Sock_Addr_Type;

   Buffer :
     Stream_Element_Array
       (1 .. Stream_Element_Offset (Snowpeak.Max_UDP_Payload_Size));
   Last : Stream_Element_Offset;

   Listener : Snowpeak.Listener.Listener;
begin
   Snowpeak.Listener.Bind (Agent_Addr, Listener);

   loop
      Receive_Socket (Listener.Channel, Buffer, Last, From => Peer_Addr);
      declare
         Got : constant Message := Read (Buffer, Last);
      begin
         Put_Line ("Agent Received: " & Got'Image);
         --  TODO: Instead of echoing, should send a proper response.
         Send_Socket (Listener.Channel, Write (Got), Last, To => Peer_Addr);
      end;
   end loop;
end Main;
