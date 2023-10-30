{ config, lib, pkgs, ... }:

let
  cfg = config.services.openfortivpn;
in
{
  options.services.openfortivpn = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable openfortivpn service";
    };

    configPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to configuration";
    };

    pppOptions = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "ppp configuration due to openfortivpn issues";
    };
  };

  config = {
    systemd.services.openfortivpn = lib.mkIf (cfg.enable && !builtins.isNull (cfg.configPath)) {
      description = "OpenFortiVPN";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.openfortivpn ];

      serviceConfig = {
        Type = "notify";
        Restart = "on-failure";
        OOMScoreAdjust = -100;
        PrivateTmp = true;
        ExecStart = "${pkgs.openfortivpn}/bin/openfortivpn -c ${cfg.configPath}";
      };
    };

    environment.etc."ppp/options" = lib.mkIf (cfg.enable && !builtins.isNull (cfg.configPath) && !builtins.isNull (cfg.pppOptions)) {
      text = cfg.pppOptions;
    };
  };
}
