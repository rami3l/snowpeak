with Ada.Text_IO; use Ada.Text_IO;

package body Snowpeak.UDP_Socket is
   procedure Bind (Addr : Sock_Addr_Type; Res : out UDP_Socket) is
   begin
      Res.Addr := Addr;
      Put_Line ("UDP_Socket launched!");
      Put_Line ("UDP_Socket: Creating socket and setting up...");
      Create_Socket (Res.Channel, Mode => Socket_Datagram);
      Set_Socket_Option (Res.Channel, Socket_Level, (Reuse_Address, True));
      Put_Line ("UDP_Socket: Listening on " & Res.Addr'Image);
      Bind_Socket (Res.Channel, Res.Addr);
   end Bind;

   procedure Receive
     (Self :     UDP_Socket; Item : out Stream_Element_Array;
      Last : out Stream_Element_Offset; Peer_Addr : out Sock_Addr_Type)
   is
   begin
      Receive_Socket (Self.Channel, Item, Last, From => Peer_Addr);
   end Receive;

   procedure Send
     (Self :     UDP_Socket; Item : Stream_Element_Array;
      Last : out Stream_Element_Offset; Peer_Addr : Sock_Addr_Type)
   is
   begin
      Send_Socket (Self.Channel, Item, Last, To => Peer_Addr);
   end Send;

   overriding procedure Finalize (Self : in out UDP_Socket) is
   begin
      Close_Socket (Self.Channel);
   end Finalize;
end Snowpeak.UDP_Socket;
