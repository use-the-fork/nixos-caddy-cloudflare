{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  ...
}: let
  info = import ./info.nix;
  dist = fetchFromGitHub info.dist;

  caddy-version = info.version;
  cloudflare-version = info.cfVersion;
in
  buildGoModule {
    pname = "caddy-with-plugins";
    version = caddy-version + "-" + cloudflare-version;

    src = ../src;

    runVend = true;
    inherit (info) vendorHash;

    preBuild = ''
      # Ensure go.mod and go.sum are updated
      go mod tidy

      # Synchronize the vendor directory
      go mod vendor
    '';

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

    meta = {
      homepage = "https://caddyserver.com";
      description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
      license = lib.licenses.asl20;
      mainProgram = "caddy";
    };
  }
