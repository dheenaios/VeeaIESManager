# WiFi / Radios

Use this tab to set radio configuration options for the APs.

The available channels depend on the country where the VeeaHub has been registered, because local regulations vary. They also depend on the capabilities of the VeeaHub model, for example, the VHE10 has upper and lower 5GHz bands.
When Auto Selection is on, the AP channel is automatically chosen for you, based on various measurements of the quality of the signal. These measurements can be seen using the Wi-Fi Network Scan option. You can override this selection by choosing a single channel from those available, and you can also restrict the selection of channels that Auto Select uses.

Auto Select is not dynamic: once the channel has been selected, this applies until the VeeaHub is restarted, or until you choose another option.

Auto Select is not available in certain circumstances, for example, on the VHC09 the 5GHz radio is shared by the APs and the wireless mesh, and the frequency channel is selected by the option on the Mesh screen.

The available settings are...

**Channel**
This is used by all four APs. By default, Auto Selection is displayed (when available). Wi-Fi uses a number of criteria to choose the best channel at the time the APs start up. If you prefer to override this and select one of the available channels, choose the channel number from the drop-down list.

**Channel in Use**
Displays the auto selected channel number.

**Auto Channel Whitelist**
This enables you to select the channels from which the auto selection occurs.

**WiFi Network Scan**
Auto Channel Scan is available on the VHC05, but these metrics are not displayed.
Tapping on the > icon displays a page showing the measurements for each channel on which the auto selection is based. It also shows the date and time these measurements were made.

The measurements are:
-  #BSS: the number of basic service sets (BSS) detected on this channel
- The minimum and maximum Received Signal Strength Indicator for the BSSs on this channel
- The noise floor on this channel
- Load: A measure of the time the channel is occupied

These measurements are combined to select a best channel for the auto select. If a channel is ranked as 0, it is not considered suitable for auto selection. If all the channels show poor results, then moving the VeeaHub to another position should be considered.

You can rescan the measurements by tapping RESCAN. This may change the channel used.

**Bandwidth**
This sets the channel selection spread, which is dependent on the channel in use. This is grayed out when the option is not available.
Possible options include: 
- 20MHz
- 20MHz/40MHz
- 20MHz/40MHz/80MHz
- 
If you are selecting this when ACS is active, ensure that the bonded channels are included in the Auto Channel Whitelist.

**Bandwidth In Use**
This displays the channel bandwidth in use.

**Mode**
Selects the 802.11 standard to use.

**Max Stations**
Specifies the maximum number of clients per AP.

**Max inactivity (in seconds)**
Specifies the maximum inactivity time after which the client is disconnected from the AP.

**Transit Power Scale (%)**
Specifies the AP transmit power.

