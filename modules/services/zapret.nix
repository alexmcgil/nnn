{ config, lib, pkgs, ... }:

{
  services.zapret-discord-youtube = {
    enable = true;
    configName = "general(ALT11)";

    gameFilter = "all";

    # Исключения по SNI: домены, которые штатные профили выбранного конфига
    # трогать не должны.
    listExclude = [
      # IP Ubisoft и Origin живут на CloudFront, а в ipset-all.txt лежат
      # широкие агрегаты 13.32.0.0/11 и 52.84.0.0/14, которые их накрывают.
      # Профиль nfqws с --ipset=ipset-all.txt принимает и
      # --hostlist-exclude=list-exclude-user.txt, поэтому эта строка реально
      # выводит лончеры из-под десинхронизации.
      "ubisoft.com"
      "origin.com"

      # Teams/Office здесь не «не обходить», а «обойти иначе» — их забирает
      # профиль из nfqwsAppend ниже. Держать их в listGeneral нельзя: тогда
      # домен достаётся штатному профилю, который для этого DPI не работает
      # (см. комментарий к nfqwsAppend).
      "cloud.microsoft"
      "cdn.office.net"
    ];

    # Своя стратегия для Teams: чистое расщепление TLS ClientHello, без fake,
    # seqovl и fooling.
    #
    # Зачем отдельный профиль. ТСПУ режет teams.cloud.microsoft по SNI — RST
    # приходит сразу после ClientHello, 0/5 успешных коннектов подряд. Обход
    # подбирался замерами на tpws (тот же код, что в nfqws), по 4 попытки на
    # стратегию: --split-pos=1 → 4/4, --split-pos=1,midsld → 4/4,
    # --split-pos=midsld → 0/4, без стратегии → 0/4. То есть достаточно
    # расщепить ClientHello после первого байта.
    #
    # Штатный профиль general(ALT11) для list-general тоже использует
    # split-pos=1, но добавляет к нему fake + seqovl=664 + fooling=ts, и в
    # такой комбинации домен остаётся недоступен — проверено ребилдом с
    # доменами в listGeneral: 0/5.
    #
    # Почему это работает в связке с listExclude: если домен попадает в
    # hostlist-exclude профиля, nfqws не бросает соединение, а передаёт его
    # следующему подходящему профилю. Проверено на двухпрофильном tpws:
    # «профиль с exclude → наш профиль» даёт 4/4, а без exclude первый
    # профиль забирает соединение себе и получается 0/4.
    #
    # Поддомены в --hostlist-domains матчатся автоматически (проверено:
    # cloud.microsoft ловит teams.cloud.microsoft, 4/4), поэтому одной строки
    # хватает на teams./m365./word./excel./outlook.cloud.microsoft.
    nfqwsAppend = [
      "--filter-tcp=443 --hostlist-domains=cloud.microsoft,cdn.office.net --dpi-desync=multisplit --dpi-desync-split-pos=1,midsld --new"
    ];

    # listGeneral/ipsetAll/ipsetExclude сознательно не задаём (дефолт модуля — []).
    # Раньше здесь стояли плейсхолдеры из README модуля — их убрали:
    #   * listGeneral = [ "example.com" "test.org" "mysite.net" ] — мусор:
    #     test.org не существует, mysite.net не отвечает. Деградацию
    #     example.com (2 замера из 5 с TLS-хендшейком 4.38 с вместо 0.33 с)
    #     этот плейсхолдер НЕ вызывал — она осталась и после удаления домена
    #     из списка. Причина в другом: IP example.com на Cloudflare попадают
    #     в агрегаты 104.20.0.0/18 и 172.66.128.0/19 из ipset-all.txt, а
    #     профиль по ipset применяет ту же fake+seqovl=664+fooling=ts. То есть
    #     это тот же дефект стратегии, что ломал Teams, только здесь
    #     соединение спасает TCP-ретрансмит по таймауту.
    #   * ipsetAll = [ "192.168.0.0/24" "10.0.0.1" ] — 192.168.0.0/24 это
    #     собственная LAN. Списку обхода блокировок она не нужна, а ipset
    #     nozapret (через который zapret выводит трафик из обработки) пуст,
    #     то есть локальный трафик реально прогонялся через nfqueue. Поломок
    #     замерить не удалось (роутер отвечает стабильно), но и смысла нет.
    #   * ipsetExclude = [ "203.0.113.0/24" ] — TEST-NET-3, диапазон,
    #     зарезервированный RFC 5737 под примеры в документации; в реальной
    #     сети не встречается.
  };

}
