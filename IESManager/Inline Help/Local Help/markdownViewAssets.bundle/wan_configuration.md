# WAN Gateway / Configuration

This screen is used to configure up to four LANs on the VeeaHub network. You should use this screen to link your AP settings with your WAN settings. 

Backhaul is the service that connects the VeeaHub network to the WAN. Typically, this is an Ethernet (wired) connection or a wireless connection. A cellular connection may be used as a back-up if the main connection fails. Veea offers a 4G Failover service as a premium option.

A VeeaHub network connects to the backhaul through a single node, designated the MEN. By default, this is the first VeeaHub that was used to create the mesh.

Any or all of the backhaul types can be enabled or disabled, if installed on the network. On the WAN configuration screen, you can place the available connections in order, so that if one connection fails, the VeeaHub will fail over to a different connection. The operational status of each backhaul type is shown.

Hold and drag the backhaul icons up/down to configure the preferred order. The backhaul type that appears at the top of the list will be preferred. If this should fail, the connection that is next in the list will be used for failover.
An option is also provided to limit the use of any backhaul for system management traffic. This is useful if the backhaul is a costly resource. For example, if you wish to reduce the cost of a cellular backhaul, enable the Restricted Backhaul setting shown in Figure 29. When this setting is enabled, the VeeaHub and other VeeaHub units in the same mesh communicate with the management and authentication server less frequently, typically once per-hour. This setting is for control traffic only and any application traffic is unaffected.

For the Wi-Fi backhaul, the SSID and passphrase can be entered on this screen. Check the instructions for your Wi-Fi service.

For the Cellular backhaul, the APN name, username and passphrase can be entered on this screen. Check the instructions for your cellular service.

**Note**. Failover is available only on a LAN configured as Routed (the default). Failover is not supported in Bridged mode.

**Note**. When you make changes to the WAN configuration and interfaces, the VeeaHub Manager App may display messages warning you of potential cost implications of additional data traffic.

The following configurations are offered...

**Ethernet / Cellular / Wi-Fi**
Use these options to enable/disable the backhaul connections and to enable/disable Restricted for each backhaul type.

**Backhaul Wi-Fi Settings**
Settings for the Wi-Fi backhaul, where installed

**SSID**
Enter the Wi-Fi SSID.

**Passphrase**
Enter the Wi-Fi passphrase.

**Backhaul Cellular Settings**
If you have subscribed to the 4G Failover service, tapping on this line displays a screen of technical information about this backhaul. For further information, contact Veea Support.

**APN**
Enter the Access Point Name (APN).

**APN Username**
Enter the username.

**Passphrase**
Enter the passphrase.


