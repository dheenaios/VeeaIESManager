## Physical Ports Tips

### Role      
Select the usage of this physical port.
WAN: As is but remove the wan settings are described in the Documentation.
LAN: This configures the port to be used as a LAN connection for other devices.

### Mesh
If enabled, a wired mesh is formed with peer hubs on the same LAN segment. Hubs can form a peer mesh on the LAN network of an MEN or MN. They can also form a mesh on the WAN network with a routed or bridged MEN. You can disable wired mesh if not required, for example if only the MEN is connected to a WAN network, or a LAN port is on an isolated segment with no peer hubs connected.

### Status
This indicates the operational state of the port.

**Grey circle** (don’t include a description of the icon in the text)
The port has never been connected and is not in use

**Orange circle with bar**
The port has been disabled

**Red circle with cross**
The port is not operational, please refer to ‘Reason’ for more information

**Green circle with tick**
The port is operational

**Triangle with Exclamation Mark**
The configuration for the port is not complete

**Document with up arrow**
The change has not yet been applied

**Blue circle**
Used to be used for ‘not in use’ but we no longer see this! Happy days…

Similarly for LAN and APs, just replace ‘port’ in the text

### Reason
Port never connected
Port disconnected

Device never presents
Device removed

DHCP conflict

### Link
Indicates if the port is active, so cabled and connected to a networking or client device.

**Green dot**
The port is active and connected to a peer networking or client device

**Grey dot**
The port is not active, either a cable is not inserted, or no link activity is detected with a peer device.

## Enabled
_Remove_: on this node, although the default settings apply across the rest of the network
_Add_: If HUB is selected, then the port is disabled on this node. If NET is selected, the port is disabled across the network, but may be overridden locally on a hub.

### Hub / Net
_Remove_: If the hub Use field is on, then this local configuration takes precedence over any network settings.

_Add_: When the changes are applied, the position of the slider determines which configuration to use. Note that if you are changing network settings for a port at the MEN, but are using the HUB settings locally, then the changes must be made to the network settings and then the slider

### Reset port button
Reset any fault conditions on the port. A disconnected port is no longer considered a fault condition. Any DHCP conflict is cleared and re-tested.
