{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.freshrss;

  poolName = "freshrss";
in
{
  options = {
    services.freshrss = {
      enable = mkEnableOption "rss-bridge";

      user = mkOption {
        type = types.str;
        default = "nginx";
        example = "nginx";
        description = ''
          User account under which both the service and the web-application run.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "nginx";
        example = "nginx";
        description = ''
          Group under which the web-application run.
        '';
      };

      pool = mkOption {
        type = types.str;
        default = poolName;
        description = ''
          Name of existing phpfpm pool that is used to run web-application.
          If not specified a pool will be created automatically with
          default values.
        '';
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/freshrss";
        description = ''
          Location in which data directory will be created.
        '';
      };

      virtualHost = mkOption {
        type = types.nullOr types.str;
        default = "freshrss";
        description = ''
          Name of the nginx virtualhost to use and setup. If null, do not setup any virtualhost.
        '';
      };


      interval = mkOption {
        type = types.str;
        default = "*:0/30";
        description = ''
          How often FreshRSS is updated. See systemd.time(7) for more
          information about the format.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.phpfpm.pools = mkIf (cfg.pool == poolName) {
      ${poolName} = {
        user = cfg.user;
        settings = mapAttrs (name: mkDefault) {
          "listen.owner" = cfg.user;
          "listen.group" = cfg.user;
          "listen.mode" = "0600";
          "pm" = "dynamic";
          "pm.max_children" = 75;
          "pm.start_servers" = 10;
          "pm.min_spare_servers" = 5;
          "pm.max_spare_servers" = 20;
          "pm.max_requests" = 500;
          "catch_workers_output" = 1;
        };
      };
    };

    services.nginx = mkIf (cfg.virtualHost != null) {
      enable = true;
      virtualHosts = {
        ${cfg.virtualHost} = {
          root = "${pkgs.freshrss}/p";

          extraConfig = "index index.php index.html index.htm;";

          locations."/" = {
            tryFiles = "$uri $uri/ index.php";
          };

          locations."~ ^.+?\.php(/.*)?$" = {
            extraConfig = ''
              include ${pkgs.nginx}/conf/fastcgi_params;
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass unix:${config.services.phpfpm.pools.${poolName}.socket};
              set $path_info $fastcgi_path_info;
              fastcgi_param PATH_INFO $path_info;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param FRESHRSS_DATA ${cfg.dataDir};
            '';
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}/data' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    system.activationScripts.freshrss = ''
      if [ ! -f ${cfg.dataDir}/data/do-not-install.txt ]; then
        mkdir -p ${cfg.dataDir}/data
        cp -vnr --no-preserve=mode,ownership ${pkgs.freshrss}/data/* ${cfg.dataDir}/data
        touch ${cfg.dataDir}/data/do-not-install.txt
      fi
    '';

    systemd = {
      services.freshrss-update = {
        environment.FRESHRSS_DATA = cfg.dataDir;
        startAt = cfg.interval;
        serviceConfig = {
          ExecStart = "${pkgs.php}/bin/php ${pkgs.freshrss}/app/actualize_script.php";
          User = "nginx";
          Group = "nginx";
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = "60";
        };
      };
    };
  };
}
