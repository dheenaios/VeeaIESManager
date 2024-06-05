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
This is a read-only setting that is configured at the gateway hub. If toggled on, then wireless network operation is enabled according to the 'WLAN Operation (Local Hub)' setting. This allows the network to extend wirelessly from these units.

If toggled off, then wireless operation is disabled at this hub provided it has a direct wired link to the gateway hub and also that the 'WLAN Operation' setting is 'Automatic'. Otherwise the normal 'WLAN Operation' setting behaviour applies.

**WLAN Operation (Local Hub)**
If set to **'Join Network'**, then the hub will join an existing wireless network identified by the SSID and provided the PSK matches. The hub must be in range of the existing wireless network.

If set to **'Start Network'**, then the hub will start a wireless network using the SSID setting. Other wireless hubs can then connect to this. Note that if two hubs are in proximity and both start a network with the same SSID, then the networks are independent.

If set to **'Disabled'**, then wireless networking is disabled and the network cannot be extended with wireless links from this hub.

If set to **'Automatic'** then the behaviour depends on whether this unit has a direct wired connection to the gateway hub and also the setting of 'WLAN Enabled (Wired Hubs)'. If there is no direct wired connection then this unit joins an existing wireless network, similar to the 'Join Network' setting. If there is a direct wired connection and 'WLAN Enabled (Wired Hubs)' is off, then wireless networking is disabled on this unit, similar to the 'Disabled' setting. If there is a direct wired connection and 'WLAN Enabled (Wired Hubs)' is on, then the unit first attempts to join an existing network and, if this is unsuccessful, it starts a new network.

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


