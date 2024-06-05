# vMesh

vMesh is Veea’s proprietary technology that enables the VeeaHubs in a network to work together. For further information, see the VeeaHub Support Center. This and other mesh parameters can be configured on this screen.

By default, the mesh is established over 5GHz Wi-Fi. It is possible to reconfigure VeeaHubs to connect over Ethernet. A VeeaHub mesh can consist of wireless links, wired links or a mixture of the two.

The mesh name and default parameters are set up when the VeeaHub is added to the account. You may wish to change the channel assignments and transmit power for improved operation in your particular circumstances (including location of units and usage of the mesh). 


**Mesh Name**
The name of the network, usually assigned when the first VeeaHub is added to the Veea account and used to create the mesh. The name can be changed here.

**SSID**
The SSID used for the network WLAN. 1 to 32 characters

**Password**
The password for the network WLAN. 8 to 63 characters (letters, digits or symbols).

**WLAN Enabled (Wired Hubs)**
**If toggled on**, then wireless network operation is enabled for any connected wired hubs. This allows the network to extend wirelessly from these units.

**If toggled off**, then wireless networking is disabled on any directly wired, remote hubs that have WLAN Operation set to 'Automatic'. The network cannot be extended with wireless links from these units.

**WLAN Operation (Local Hub)**
If set to **'Start Network'**, then the hub supports wireless networking and will start a network identified by the SSID setting. Other hubs can connect to this unit wirelessly using the SSID and matching PSK.

If set to**'Disabled'**, then wireless networking is disabled and the network cannot be extended with wireless links from this hub.

**Channel**
This enables selection of the Wi-Fi channel for the wireless mesh. The set of available channels is restricted, based on the configured VeeaHub location.
By default, Auto Selection is displayed. A number of criteria are used to choose the best channel at the time the mesh starts up. If you prefer to override this and select one of the available channels, choose the channel number from the list.

Auto Selection is available only on the VHE09 and VHE10 models.

**Channel in Use**
The channel chosen by Auto Selection.

**Exclude DFS**
This switch, when selected, prevents channels that are designated for Dynamic Frequency Selection being used for Auto Selection. 

**Auto Channel Whitelist**
This dropdown enables you to specify which channels will be used for Auto Channel selection.

**WiFi Network Scan**
When Auto Select is in operation, this displays the Scan screen 

**Bandwidth**
Select the bandwidth for the network LAN.

**Bandwidth in use**
This shows the currently selected bandwidth.

**Transmit Power**
Select the mesh transmit power (as a % of maximum).

**Enable Beacon**
Not available on a gateway node. This is used on a non-gateway node to create a new Wi-Fi mesh using the SSID above. In normal use this should be OFF at all nodes.


