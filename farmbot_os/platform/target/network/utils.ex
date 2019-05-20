defmodule FarmbotOS.Platform.Target.Network.Utils do
  import FarmbotCore.Config, only: [get_config_value: 3]
  require FarmbotCore.Logger
  alias FarmbotOS.Platform.Target.Network.ScanResult

  def build_hostap_ssid do
    {:ok, hostname} = :inet.gethostname()

    if String.starts_with?(to_string(hostname), "farmbot-") do
      to_string('farmbot-' ++ Enum.take(hostname, -4))
    else
      to_string(hostname)
    end
  end

  @doc "Scan on an interface."
  def scan(iface) do
    []
  end

  @doc "Tests if we can make dns queries."
  def test_dns(hostname \\ nil)

  def test_dns(nil) do
    case get_config_value(:string, "authorization", "server") do
      nil ->
        test_dns(get_config_value(:string, "settings", "default_dns_name"))

      url when is_binary(url) ->
        %URI{host: hostname} = URI.parse(url)
        test_dns(hostname)
    end
  end

  def test_dns(hostname) when is_binary(hostname) do
    test_dns(to_charlist(hostname))
  end

  def test_dns(hostname) do
    :ok = :inet_db.clear_cache()

    case :inet.parse_ipv4_address(hostname) do
      {:ok, addr} -> {:ok, {:hostent, hostname, [], :inet, 4, [addr]}}
      _ -> :inet_res.gethostbyname(hostname)
    end
  end

  @fb_data_dir FarmbotOS.FileSystem.data_path()
  @tzdata_dir Application.app_dir(:tzdata, "priv")
  def maybe_hack_tzdata do
    case Tzdata.Util.data_dir() do
      @fb_data_dir ->
        :ok

      _ ->
        FarmbotCore.Logger.debug(3, "Hacking tzdata.")
        objs_to_cp = Path.wildcard(Path.join(@tzdata_dir, "*"))

        for obj <- objs_to_cp do
          File.cp_r(obj, @fb_data_dir)
        end

        Application.put_env(:tzdata, :data_dir, @fb_data_dir)
        :ok
    end
  end
end
