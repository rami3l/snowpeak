with Ada.Exceptions;   use Ada.Exceptions;
with Ada.Streams;      use Ada.Streams;
with Ada.Text_IO;      use Ada.Text_IO;
with GNAT.Sockets;     use GNAT.Sockets;
with RFLX.RFLX_Types;
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

   Socket  : Snowpeak.UDP_Socket.UDP_Socket;
   Querier : Snowpeak.Querier.Map_Querier;

   Count : Integer := 0;

   --  REQUIRED FOR DUMMY QUERIER
   package Types renames RFLX.RFLX_Types;
   Dummy_OID_Bytes : Types.Bytes     := [43, 6, 1, 2, 1, 1, 5, 0];
   Dummy_Name      : Types.Bytes_Ptr := new Types.Bytes'([70, 54, 51, 48, 48]);
begin
   --  INIT OF DUMMY QUERIER
   declare
      Element : Varbind;
   begin
      for B of Dummy_OID_Bytes loop
         Element.OID.Push (Types.Byte (B));
      end loop;
      Element.Variable := (Tag_Num => 4, Data => Dummy_Name, others => <>);

      Querier.Data.Push (Element);
   end;

   --  START OF MAIN PROGRAM
   Put_Line ("=== Hello from Snowpeak! ===");
   Snowpeak.UDP_Socket.Bind (Agent_Addr, Socket);
   Put_Line ("");

   loop
      Put_Line ("=== LOOP #" & Count'Image & " ===");
      Socket.Receive (Buffer, Last, Peer_Addr);
      Put_Line ("Datagram Received.");
      declare
         Got, Resp : Message;
      begin
         Got := Read (Buffer, Last);
         Put_Line ("Received Message From: " & Peer_Addr'Image);
         Put_Line ("Received Message: " & Got'Image);
         Put_Line ("Message Length: " & Got.Length'Image);
         Put_Line ("");
         Resp := Querier.Respond (Got);
         Put_Line ("Response Message: " & Resp'Image);
         Socket.Send (Write (Resp), Last, Peer_Addr);
      exception
         when E : Constraint_Error =>
            Put_Line (Exception_Message (E));
            goto Continue;
      end;
      <<Continue>>
      Count := Count + 1;
      Put_Line ("");
   end loop;
end Main;
