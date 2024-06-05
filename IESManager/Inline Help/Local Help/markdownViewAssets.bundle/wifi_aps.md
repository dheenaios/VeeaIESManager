# WiFi / Access Points

These Wi-Fi settings allow configuration of different Wi-Fi parameters.

The VeeaHub supports up to four virtual APs on each band (three on the VHC05). These APs are multiplexed on a single Wi-Fi device across a single Wi-Fi channel, which is configured for all of the four virtual APs.

AP configurations are shown as cards with the following UI elements...

**Status Bar**
The current status of this AP is displayed with a symbol, for example, Active, Not in use, Disabled, Incomplete, Changes not applied and A status message.

**Hub/Network**
The selection indicates if the AP is assigned to the Hub or to the Network Mesh.

On the gateway VeeaHub (MEN), set this to Network to apply the settings to this AP on all nodes across the VeeaHub network.

On any VeeaHub, set this to Hub to apply the settings to the AP on this node alone. This overrides any mesh-wide settings for this AP.

**Hidden**
When set this hides the SSID from client devices.

**Enabled**

If the Enabled switch is on, the AP has the settings that are configured here. If the Enabled switch is off, the AP is disabled on this VeeaHub, even if it is configured for the whole network (see Hub or Network, below).

**SSID**
This is used to specify the SSID for the virtual AP.

**Security Type (not on VHC05)**
This displays the type of security in effect on this AP. The default is PSK. Tap on Configure in order to make changes to this setting.

**Password (VHC05 only)**
Specify a password that the user must enter in order to connect to this AP. Leave blank if a password Is not required.

---

The VeeaHub offers three security types: Open, Pre-Shared Key (PSK) and Enterprise. The default is PSK. Different APs on one VeeaHub can be configured with different security types.

Note: This does not apply to the VHC05 model, which has only PSK, which can be configured with or without a password.

Use Open if you do not require the user to enter a password in order to connect to an AP. There are no further configuration options.

PSK is the default and is used if you want the user to know a password in order to connect to the AP.

Enterprise security requires authentication on a separate server called a Remote Authentication Dial-In User Service (RADIUS) server. This option will typically be used if the VeeaHub is installed in a business network where this security type is used.

The security options are...

## Open Security

No password is required for anyone to connect to an AP with Open security. There are no further options to set.

## PSK Security

A password must be set up on the VeeaHub. This password must be known by a user in order to connect their mobile device to this AP. 

The PSK configuration options are...

**SSID**

Not editable on this screen. 

**WPA Mode**

You can select to allow client devices to connect with WPA2 only, WPA3 only, or either.

**802.11r**

When set, this enables client devices to fast transition between network APs that are configured with the same SSID. This is currently available only on the 09/10 models. Enabling 802.11r may mean that some older devices without this capability cannot connect to this SSID.

**802.11w**

This option is available only when **WPA2 Only** is selected. The values are **Enabled, Disabled or Required**. This enhancement to security is set to Enabled by default: devices with or without 802.11w can connect. If set to Required, only devices that support 802.11w will be able to connect.

## Enterprise Security

This option is for VeeaHubs in enterprise networks. Your system administrator will provide necessary information.

Authentication is performed by contacting a specialized server, called a RADIUS Authentication server. RADIUS may also be used to collect data on usage for billing purposes on an Accounting server. These servers must already be configured before this security option can be used.

RADIUS server details must be set up on the gateway VeeaHub (MEN) before a selection can be made on other nodes in the mesh.

The Enterprise configuration options are...

**SSID**

Not editable on this screen. 

**WPA Mode**

You can select to allow client devices to connect with WPA2 only, WPA3 only, or either.

**Radius Authentication**

Primary and secondary servers can be configured. The secondary server is optional and acts as a backup if the primary server is unavailable.

For each server, enter the required details: the IP Address of the server, the port number (default 1812) and the secret for access to the server.

The secret must be known by a user in order to connect their mobile device to this AP.

**Radius Accounting**

Enable the switch if this option is required. The configuration is similar to RADIUS Authentication. The default port number for RADIUS accounting is 1813.

