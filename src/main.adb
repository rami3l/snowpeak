with Ada.Exceptions;   use Ada.Exceptions;
with Ada.Streams;      use Ada.Streams;
with Ada.Text_IO;      use Ada.Text_IO;
with GNAT.Sockets;     use GNAT.Sockets;
with Snowpeak.UDP_Socket;
with Snowpeak.Message; use Snowpeak.Message;
with Snowpeak.Querier;
with Snowpeak;

procedure Main is
   Agent_Port : constant Port_Type := 10_161;
   --  Changed from 161 to 10161 to avoid Linux permission issues.
   Agent_Addr : constant Sock_Addr_Type :=
     (Addr => Inet_Addr ("127.0.0.1"), Port => Agent_Port, others => <>);
   Peer_Addr : Sock_Addr_Type;

   Buffer :
     Stream_Element_Array
       (1 .. Stream_Element_Offset (Snowpeak.Max_UDP_Payload_Size));
   Last : Stream_Element_Offset;

   Socket : Snowpeak.UDP_Socket.UDP_Socket;
   Querier : Snowpeak.Querier.Map_Querier;
begin
   Put_Line ("=== Hello from Snowpeak! ===");
   Snowpeak.UDP_Socket.Bind (Agent_Addr, Socket);

   loop
      Socket.Receive (Buffer, Last, Peer_Addr);
      Put_Line ("Datagram Received.");
      declare
         Got, Resp: Message;
      begin
         Got := Read (Buffer, Last);
         Put_Line ("Received Message: " & Got'Image);
         Put_Line ("Message Length: " & Got.Length'Image);
         --  TODO: Instead of echoing, should send a proper response.
         Resp := Querier.Respond (Got);
         Put_Line ("Response Message: " & Resp'Image);
         Socket.Send (Write (Resp), Last, Peer_Addr);
      exception
         when E : Constraint_Error =>
            Put_Line (Exception_Message (E));
            goto Continue;
      end;
      <<Continue>>
   end loop;
end Main;
