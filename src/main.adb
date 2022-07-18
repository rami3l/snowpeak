with Ada.Exceptions;   use Ada.Exceptions;
with Ada.Streams;      use Ada.Streams;
with Ada.Text_IO;      use Ada.Text_IO;
with GNAT.Sockets;     use GNAT.Sockets;
with Snowpeak.Listener;
with Snowpeak.Message; use Snowpeak.Message;
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

   Listener : Snowpeak.Listener.Listener;
begin
   Put_Line ("=== Hello from Snowpeak! ===");
   Snowpeak.Listener.Bind (Agent_Addr, Listener);

   loop
      Listener.Receive (Buffer, Last, Peer_Addr);
      Put_Line ("Datagram Received.");
      declare
         Got : Message;
      begin
         Got := Read (Buffer, Last);
         Put_Line ("Received Message: " & Got'Image);
         Put_Line ("Message Length: " & Got.Length'Image);
         --  TODO: Instead of echoing, should send a proper response.
         --  Send_Socket (Listener.Channel, Write (Got), Last, To => Peer_Addr);
      exception
         when E : Constraint_Error =>
            Put_Line ("Invalid Buffer detected!");
            Put_Line (Exception_Message (E));
            Put_Line ("Got: " & Buffer'Image);
      end;
   end loop;
end Main;
