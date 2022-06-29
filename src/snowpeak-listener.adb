with Ada.Text_IO; use Ada.Text_IO;

package body Snowpeak.Listener is
   procedure Bind (Addr : Sock_Addr_Type; Res : out Listener) is
   begin
      Res.Addr := Addr;
      Put_Line ("Listener launched!");
      Put_Line ("Listener: Creating socket and setting up...");
      Create_Socket (Res.Channel, Mode => Socket_Datagram);
      Set_Socket_Option (Res.Channel, Socket_Level, (Reuse_Address, True));
      Put_Line ("Listener: Binding socket...");
      Bind_Socket (Res.Channel, Res.Addr);
      -- Put_Line ("Listener: Listening socket...");
      -- Listen_Socket (Res.Channel);
   end Bind;

   procedure Receive
     (Self : in     Listener; Item : out Stream_Element_Array;
      Last :    out Stream_Element_Offset; Peer_Addr : out Sock_Addr_Type)
   is
   begin
      Receive_Socket (Self.Channel, Item, Last, From => Peer_Addr);
   end Receive;

   overriding procedure Finalize (Self : in out Listener) is
   begin
      Close_Socket (Self.Channel);
   end Finalize;
end Snowpeak.Listener;
