{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  ...
}: let
  info = import ./info.nix;
  dist = fetchFromGitHub info.dist;
  version = info.version + "_cf" + info.cfVersion;
in
  buildGoModule {
    pname = "caddy";
    inherit version;

    src = ../caddy-src;

    runVend = true;
    inherit (info) vendorHash;

    # Everything past this point is from Nixpkgs
    ldflags = [
      "-s"
      "-w"
    ];

    nativeBuildInputs = [installShellFiles];
    postInstall = ''
      install -Dm644 ${dist}/init/caddy.service ${dist}/init/caddy-api.service -t $out/lib/systemd/system

      substituteInPlace $out/lib/systemd/system/caddy.service --replace "/usr/bin/caddy" "$out/bin/caddy"
      substituteInPlace $out/lib/systemd/system/caddy-api.service --replace "/usr/bin/caddy" "$out/bin/caddy"

      $out/bin/caddy manpage --directory manpages
      installManPage manpages/*

      installShellCompletion --cmd caddy \
        --bash <($out/bin/caddy completion bash) \
        --fish <($out/bin/caddy completion fish) \
        --zsh <($out/bin/caddy completion zsh)
    '';

    meta = with lib; {
      homepage = "https://caddyserver.com";
      description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
      license = licenses.asl20;
      mainProgram = "caddy";
    };
  }
