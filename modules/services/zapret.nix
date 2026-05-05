{ config, lib, pkgs, ... }:

{
  services.zapret-discord-youtube = {
    enable = true;
    configName = "general(ALT11)";
    
    gameFilter = "all";
    
    # Добавляем кастомные домены в list-general-user.txt
    listGeneral = [ "example.com" "test.org" "mysite.net" ];
    
    # Добавляем домены в list-exclude-user.txt (исключения)
    listExclude = [ "ubisoft.com" "origin.com" ];
    
    # Добавляем IP адреса в ipset-all.txt
    ipsetAll = [ "192.168.0.0/24" "10.0.0.1" ];
    
    # Добавляем IP адреса в ipset-exclude-user.txt (исключения)
    ipsetExclude = [ "203.0.113.0/24" ];
  };

}
