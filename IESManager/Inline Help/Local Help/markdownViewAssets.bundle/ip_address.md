# IP Address

This screen is available only on a gateway VeeaHub (MEN).

The title section shows the IP address of the VeeaHub. If the VeeaHub is configured as a MEN, it also shows the backhaul type.

The following configurations are offered...

**IP address**
The external IP address of the VeeaHub, and the backhaul type.

**Delegated prefix**
Used to assign IP addresses to VeeaHub devices in the network. In the case of IPv4 operation this is a private IP prefix space. You should not need to change this value, unless the backhaul interface also has the same prefix. Changing this field will cause the MEN too reboot.

**MEN mesh address**
Defines the IP address of the MEN on the mesh. This should be within the delegated prefix address range. Changing this field will cause the MEN to reboot.

**Internal prefix**
Used to assign IP addresses to stations connected to the VeeaHub APs while the VeeaHub is not connected to a mesh.

**Primary DNS server**
The backhaul network interface DNS is propagated across the vMesh. If the backhaul network does not have DNS, this should be configured to point to an external DNS.

**Secondary DNS server**
The backhaul network interface DNS is propagated across the vMesh. If the backhaul network does not have DNS, this should be configured to point to an external DNS.


