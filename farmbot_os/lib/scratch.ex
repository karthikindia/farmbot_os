defmodule Scratch do
  def ap do
    VintageNet.configure("wlan0", config())
  end

  def client do
    config = %{
      type: VintageNet.Technology.WiFi,
    }
    VintageNet.configure("wlan0", config)
  end

  def null do
    VintageNet.configure("wlan0", %{type: VintageNet.Technology.Null})
  end


  def config do
    %{
      type: VintageNet.Technology.WiFi,
      wifi: wifi(),
      ipv4: ipv4(),
      dhcpd: dhcpd()
    }
  end

  defp wifi do
    %{
      mode: :host,
      ssid: "test ssid",
      key_mgmt: :none,
      ap_scan: 1,
      bgscan: :simple
    }
  end

  def ipv4 do
    %{
      method: :static,
      address: "192.168.24.1",
      netmask: "255.255.255.0",
      gateway: "192.168.24.1"
    }
  end

  def dhcpd do
    %{
      start: "192.168.24.2",
      end: "192.168.24.20"
    }
  end
end
