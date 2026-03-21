{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = [
    pkgs.flutter
    pkgs.android-tools
    pkgs.jdk17
    pkgs.git
  ];
  env = {
    JAVA_HOME = "${pkgs.jdk17}";
    FLUTTER_ANALYTICS = "false";
  };
  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];
    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "flutter"
            "run"
            "--machine"
            "-d" "web-server"
            "--web-port" "$PORT"
            "--web-hostname" "0.0.0.0"
            "--dart-define=USE_MOCK=true"
          ];
          manager = "flutter";
        };
      };
    };
  };
}
