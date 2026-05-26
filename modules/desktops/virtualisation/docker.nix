#
#  Docker
#
{pkgs, ...}: {
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for docker compose stacks to resolve service names on the default network.
      defaultNetwork.settings.dns_enabled = true;
    };

    containers.containersConf.settings.engine = {
      compose_providers = ["${pkgs.docker-compose}/bin/docker-compose"];
      # compose_warning_logs = false;
    };
  };

  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # `docker compose` provider (via podman + dockerCompat)
  ];
}
