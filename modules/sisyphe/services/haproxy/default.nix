{
  mainDomain,
  ...
}:

{
  custom.services.haproxy = {
    enable = true;

    global = {
      maxconn = 4000;
      daemon = true;
    };

    defaults = {
      maxconn = 4000;

      extraConfig = ''
        log                     global
        option                  dontlognull
        option                  redispatch
        retries                 3
        timeout http-request    10s
        timeout queue           1m
        timeout connect         10s
        timeout client          1m
        timeout server          1m
        timeout http-keep-alive 10s
        timeout check           10s
      '';
    };

    defaultBackend = mainDomain;
  };
}
