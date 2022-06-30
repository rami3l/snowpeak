with Ada.Streams;      use Ada.Streams;
with Ada.Text_IO;      use Ada.Text_IO;
with GNAT.Sockets;     use GNAT.Sockets;
with Snowpeak.Listener;
with Snowpeak.Message; use Snowpeak.Message;

procedure Main is
   Max_UDP_Payload_Size : constant Stream_Element_Offset := 576 - 60 - 8;
   --  See: https://stackoverflow.com/a/35697810

   Agent_Addr : constant Sock_Addr_Type :=
     (Addr => Inet_Addr ("127.0.0.1"), Port => 161, others => <>);
   Peer_Addr : Sock_Addr_Type;

   Buffer : Stream_Element_Array (1 .. Max_UDP_Payload_Size);
   Last   : Stream_Element_Offset;

   Listener : Snowpeak.Listener.Listener;
begin
   Snowpeak.Listener.Bind (Agent_Addr, Listener);

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
end Main;
