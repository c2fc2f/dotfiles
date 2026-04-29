/*
  UPower, a system service that provides power management support for laptops
  and desktops. It offers information about battery status, power supply, and
  can emit signals for power-related events (e.g., low battery warnings).

  UPower is commonly used by desktop environments and panel applets to display
  battery and power status.
*/
{ services.upower.enable = true; }
