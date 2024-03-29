with Ada.Finalization;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Streams;  use Ada.Streams;

package Snowpeak.UDP_Socket is
   type UDP_Socket is new Ada.Finalization.Controlled with record
      Addr    : Sock_Addr_Type;
      Channel : Socket_Type;
   end record;
   --  A thin wrapper around GNAT.Socket's UDP socket feature.
   --  https://doc.rust-lang.org/std/net/struct.UdpSocket.html

   procedure Bind (Addr : Sock_Addr_Type; Res : out UDP_Socket);
   --  Bind specifies the listening address of this socket.

   procedure Receive
     (Self :     UDP_Socket; Item : out Stream_Element_Array;
      Last : out Stream_Element_Offset; Peer_Addr : out Sock_Addr_Type);
   --  Receives a byte sequence from a unspecified peer address.

   procedure Send
     (Self :     UDP_Socket; Item : Stream_Element_Array;
      Last : out Stream_Element_Offset; Peer_Addr : Sock_Addr_Type);
   --  Sends a byte sequence to a peer address.

   overriding procedure Finalize (Self : in out UDP_Socket);
end Snowpeak.UDP_Socket;
