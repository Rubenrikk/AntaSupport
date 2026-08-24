import Foundation

// ─────────────────────────────────────────────────────────────────────────────
//  Standaard snippets, gegroepeerd per categorie.
//
//  Dit is de startset. Voeg je eigen snippets toe door regels bij te plakken —
//  één `Snippet(...)` per commando. Velden:
//    • name      : label in de lijst
//    • template  : het commando, met {{veld}} of {{veld:default}} placeholders
//    • category  : de kop waaronder het valt in de sidebar — de volgorde
//                  waarin categorieën getoond worden staat in `categoryOrder`
//                  hieronder, niet in de volgorde van dit bestand.
//    • cage      : true  → moet in de cage draaien (krijgt een slot-badge)
//                  false → hoeft niet in de cage
//    • tags      : optioneel, doorzoekbaar
//
//  Tip: gebruik "Reset to Default Snippets" in het Snippets-menu om je lijst
//  terug te zetten naar precies wat hieronder staat.
// ─────────────────────────────────────────────────────────────────────────────

extension Snippet {
    /// Weergavevolgorde van de ingebouwde categorieën: eerst inloggen, dan
    /// domeinen afsluiten/deblokkeren, dan malware- en WP-scans, en daarna
    /// ruwweg van vaak- naar weinig-voorkomend. Eigen categorieën die hier
    /// niet in staan worden er alfabetisch achteraan geplakt.
    static let categoryOrder: [String] = [
        "Inloggen",
        "Afsluiten & deblokkeren",
        "Malware & Spam scannen",
        "WordPress verify-checksums",
        "Mail",
        "Schijfruimte",
        "Logs",
        "Firewall",
        "Hostingpakket",
        "Backup transfer",
        "DNS",
        "Snapshots",
        "Bestandsrechten",
        "Database",
        "Bot-traffic",
        "Systeem",
        "Screen & Tmux",
        "Reseller",
        "Redis",
        "Nextcloud",
    ]

    static let defaults: [Snippet] = [

        // ── Inloggen ────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "7F912207-DCE3-4169-B894-58344D895B1F")!,
                name: "SSH naar jump server", template: "ssh ssh2.nl",
                category: "Inloggen", tags: ["ssh", "login"]),
        Snippet(id: UUID(uuidString: "FB3ECF66-4C6B-4CDB-B84A-C2745B391945")!,
                name: "Naar antasupport", template: "antasupport",
                category: "Inloggen", tags: ["login"]),
        Snippet(id: UUID(uuidString: "5F061E1E-04B4-40AC-8D75-FD2FFF015400")!,
                name: "Naar server (BabySSH)", template: "ssh {{server:s199}}",
                category: "Inloggen", tags: ["ssh", "login"]),
        Snippet(id: UUID(uuidString: "E2F012AB-0D42-4DFA-939A-F5F47BFCFE87")!,
                name: "Inloggen op de cage van gebruiker",
                template: "sudo antasupport enter_cage {{debuser:deb12345}}",
                category: "Inloggen", tags: ["cage", "login"]),

        // ── Afsluiten & deblokkeren ──────────────────────────
        Snippet(id: UUID(uuidString: "F436831D-1F8E-4111-AE33-7B8AD152D02A")!,
                name: "Domein afsluiten (suspend)",
                template: "sudo antasupport domain_suspend {{debuser:deb12345}} {{domein:voorbeeld.nl}}",
                category: "Afsluiten & deblokkeren", tags: ["suspend"]),
        Snippet(id: UUID(uuidString: "DC4AB952-C7C2-4B2E-82ED-EB43FF926DDC")!,
                name: "Meerdere domeinen suspenden (script)", template: #"""
                DEBUSER={{debuser:deb12345}}
                block_domains=({{domeinen:domeinnaam1.nl domein2.com}});
                for ((i = 0; i < ${#block_domains[@]}; i++)); do
                	sudo antasupport domain_suspend $DEBUSER ${block_domains[$i]}
                done
                """#,
                category: "Afsluiten & deblokkeren", tags: ["suspend", "script"]),
        Snippet(id: UUID(uuidString: "B980D8AE-593C-46B3-8920-6D59A016F9C2")!,
                name: "Domein deblokkeren (unsuspend)",
                template: "sudo antasupport domain_unsuspend {{debuser:deb12345}} {{domein:voorbeeld.nl}}",
                category: "Afsluiten & deblokkeren", tags: ["unsuspend"]),
        Snippet(id: UUID(uuidString: "99255F03-5751-4527-8480-C39BE015DB17")!,
                name: "Domein deblokkeren (Reseller user)",
                template: "sudo antasupport domain_unsuspend {{debuser:deb12345}} {{domein:voorbeeld.nl}}",
                category: "Afsluiten & deblokkeren", tags: ["unsuspend", "reseller"]),
        Snippet(id: UUID(uuidString: "C2A9286F-EAD4-48C5-B9EA-F3C0F6605722")!,
                name: "Wachtwoordbeveiliging instellen (protect)",
                template: "sudo antasupport domain_protect {{debuser:deb12345}} {{domein:voorbeeld.nl}}",
                category: "Afsluiten & deblokkeren", tags: ["protect"]),
        Snippet(id: UUID(uuidString: "283D1197-8A49-469F-B4AE-2E4B4131403F")!,
                name: "Wachtwoordbeveiliging verwijderen (unprotect)",
                template: "sudo antasupport domain_unprotect {{debuser:deb12345}} {{domein:voorbeeld.nl}}",
                category: "Afsluiten & deblokkeren", tags: ["unprotect"]),

        // ── Malware & Spam scannen ──────────────────────────────────
        Snippet(id: UUID(uuidString: "D9A45237-9FB4-4D27-99D9-9C68903C4DC3")!,
                name: "Eval-grep (alle bestanden)",
                template: #"sudo grep -lir "eval(" /home/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html/"#,
                category: "Malware & Spam scannen", tags: ["malware", "eval"]),
        Snippet(id: UUID(uuidString: "FDB200DC-F8FE-4967-9B97-D6B1857BCFC4")!,
                name: "findspam (.php-bestanden)",
                template: "sudo antasupport findspam /home/{{debuser:deb12345}}",
                category: "Malware & Spam scannen", tags: ["malware", "findspam"]),
        Snippet(id: UUID(uuidString: "3A471AFF-F128-4610-B273-4E4C28CB22F7")!,
                name: "findspam binnen gedeeld pakket (script per domein)", template: #"""
                DEBUSER={{debuser:deb12345}}
                domains=$(sudo ls /home/${DEBUSER}/domains/);
                for DOMAIN in $domains; do
                	echo "findspam gestart voor: ${DOMAIN}";
                	sudo antasupport findspam /home/$DEBUSER/domains/${DOMAIN}/public_html
                	echo "";
                done;
                """#,
                category: "Malware & Spam scannen", tags: ["malware", "findspam", "script"]),
        Snippet(id: UUID(uuidString: "D264D1CA-F190-4A73-8038-59B6E91353B2")!,
                name: "PHP-bestanden met 'goto' zoeken",
                template: #"find $(pwd) -type f -name '*.php' -exec grep -liR " goto " {} \;"#,
                category: "Malware & Spam scannen", cage: true, tags: ["malware"]),
        Snippet(id: UUID(uuidString: "0394A0A6-E78F-4ABB-9CE6-C01EB0BCE038")!,
                name: ".htaccess met verdachte strings zoeken",
                template: #"find $(pwd) -type f -name '.htaccess' -exec grep -liR "{{zoekterm:checkbox.php|export.php|input.php}}" {} \;"#,
                category: "Malware & Spam scannen", cage: true, tags: ["malware"]),
        Snippet(id: UUID(uuidString: "DCBF4789-6123-4DD9-8E24-768611A2C1EF")!,
                name: "Malware melden aan Patchman",
                template: #"sudo antasupport patchmanreport {{bestandspad}} malware "{{omschrijving:This is a malicious file which sends spam}}""#,
                category: "Malware & Spam scannen", tags: ["malware", "patchman"]),
        Snippet(id: UUID(uuidString: "3D73C413-EFBC-4AED-8BFA-34386431B792")!,
                name: "Grep op tekst binnen gedeeld pakket (script)", template: #"""
                export SEARCHFOR='{{zoekterm}}'
                domains=$(ls /home/$(whoami)/domains/);
                for DOMAIN in $domains; do
                if [ ! -L "/home/$(whoami)/domains/${DOMAIN}/private_html" ]; then
                 grep -liR "${SEARCHFOR}" /home/$(whoami)/domains/${DOMAIN}/private_html
                fi
                if [ ! -L "/home/$(whoami)/domains/${DOMAIN}/public_html" ]; then
                 grep -liR "${SEARCHFOR}" /home/$(whoami)/domains/${DOMAIN}/public_html
                fi
                done
                """#,
                category: "Malware & Spam scannen", cage: true, tags: ["malware", "script"]),
        Snippet(id: UUID(uuidString: "B631F443-A8A7-4A9C-AFCE-ABB396A2248A")!,
                name: "Grep op bestandsnaam binnen gedeeld pakket (script)", template: #"""
                export SEARCHFILE='{{bestandsnaam:wp-craft-report.php}}'
                domains=$(ls /home/$(whoami)/domains/);
                for DOMAIN in $domains; do
                 if [ -d "/home/$(whoami)/domains/${DOMAIN}/public_html" ]; then
                   MALFILES=$(find /home/$(whoami)/domains/${DOMAIN}/public_html -name "${SEARCHFILE}");
                for malfile in "${MALFILES[@]}"; do
                echo $malfile
                done;
                  fi
                done
                """#,
                category: "Malware & Spam scannen", cage: true, tags: ["malware", "script"]),

        // ── WordPress verify-checksums ──────────────────────────────
        Snippet(id: UUID(uuidString: "2866F536-1B23-4F96-A4E9-39B68B2713D5")!,
                name: "Verify checksums (huidige map)", template: "wp core verify-checksums",
                category: "WordPress verify-checksums", cage: true, tags: ["wp", "wp-cli"]),
        Snippet(id: UUID(uuidString: "4990E2B4-E4D8-4EFB-84B2-213129DDA724")!,
                name: "Verify checksums alle WP-sites in domains (script)", template: #"""
                find /home/*/domains -name "wp-config.php" -print0 | while read -d $'\0' file; do
                    INSTALL_FOLDER=$(dirname "$file")
                    INSTALL_WP_VERSION=$(wp core version --skip-themes --skip-plugins --path="${INSTALL_FOLDER}")
                    echo " • Installatie in: ${INSTALL_FOLDER} (WordPress ${INSTALL_WP_VERSION})"
                    wp core verify-checksums --skip-themes --skip-plugins --version="${INSTALL_WP_VERSION}" --path="${INSTALL_FOLDER}" 2>&1
                    printf "\n\n-------------------------------------------\n\n"
                done
                """#,
                category: "WordPress verify-checksums", cage: true, tags: ["wp", "wp-cli", "script"]),
        Snippet(id: UUID(uuidString: "3EB421FC-9136-45DC-A37E-D32D10E9F937")!,
                name: "Verify checksums per domein (loop)", template: """
                for site in /home/{{debuser:deb12345}}/domains/*/public_html; do
                  echo "=== $site ==="
                  wp core verify-checksums --path="$site" --skip-plugins --skip-themes 2>&1
                  echo
                done
                """,
                category: "WordPress verify-checksums", cage: true, tags: ["wp", "wp-cli", "script"]),
        Snippet(id: UUID(uuidString: "A0DD568B-E439-47A9-87AD-B77C3666877B")!,
                name: "Plugin uitzetten (huidige map)",
                template: "wp plugin deactivate {{plugin:plugin-slug}}{{--skip-plugins:flag: --skip-plugins}}{{--skip-themes:flag: --skip-themes}}",
                category: "WordPress verify-checksums", cage: true, tags: ["wp", "wp-cli", "debug"],
                note: "Vink --skip-plugins/--skip-themes aan als de installatie zelf een 500 error geeft, zodat wp-cli de kapotte plugin/thema niet laadt."),
        Snippet(id: UUID(uuidString: "3003D292-0119-40FB-9039-D8F0F8BC2172")!,
                name: "Thema activeren (huidige map)",
                template: "wp theme activate {{theme:twentytwentyfour}}{{--skip-plugins:flag: --skip-plugins}}{{--skip-themes:flag: --skip-themes}}",
                category: "WordPress verify-checksums", cage: true, tags: ["wp", "wp-cli", "debug"],
                note: "Vink --skip-plugins/--skip-themes aan als de installatie zelf een 500 error geeft, zodat wp-cli de kapotte plugin/thema niet laadt."),

        // ── Mail ─────────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "ACC32248-3F75-409A-B964-4B6DEB858366")!,
                name: "Mailaccount wachtwoord resetten",
                template: "sudo antasupport reset_emailpassword {{emailadres:henkdepanda@example.nl}}",
                category: "Mail", tags: ["mail", "password"]),

        // ── Schijfruimte ────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "2348F2C9-A886-4BE7-964C-A09C0DA3CDED")!,
                name: "Disk usage pakket",
                template: "sudo antasupport du /home/{{debuser:deb12345}}/",
                category: "Schijfruimte", tags: ["disk"]),
        Snippet(id: UUID(uuidString: "76A60DF3-AF48-452D-A702-8E7752D20B84")!,
                name: "Disk usage specifieke map",
                template: "sudo antasupport du /home/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html/",
                category: "Schijfruimte", tags: ["disk"]),
        Snippet(id: UUID(uuidString: "2EAE61F3-B3DF-4D53-9C67-5D3C27FC5085")!,
                name: "du -h (huidige map)", template: """
                cd /home/{{debuser:deb12345}}/
                du -h --max-depth=1
                """,
                category: "Schijfruimte", cage: true, tags: ["disk"]),
        Snippet(id: UUID(uuidString: "40A3BBE6-3A80-4EDB-8054-DC86D13489A6")!,
                name: "ncdu op pakket (op server)",
                template: "sudo ncdu /home/{{debuser:deb12345}}",
                category: "Schijfruimte", tags: ["disk", "ncdu"],
                note: "Na het laden van ncdu kun je inodes tonen met c + C."),

        // ── Logs ────────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "C5D1262F-A706-424C-A3F6-7F4EC1CEA4C0")!,
                name: "Error-log: zoeken op tekst",
                template: "sudo grep '{{zoekterm:Fatal}}' /var/log/httpd/domains/{{domein:voorbeeld.nl}}.error.log",
                category: "Logs", tags: ["errorlog"]),
        Snippet(id: UUID(uuidString: "C16FDBC8-6DA3-4ABC-8B46-FD7592C266EE")!,
                name: "Error-log: zoeken zonder hoofdlettergevoeligheid",
                template: "sudo grep -i '{{zoekterm:fatal}}' /var/log/httpd/domains/{{domein:voorbeeld.nl}}.error.log",
                category: "Logs", tags: ["errorlog"]),
        Snippet(id: UUID(uuidString: "34DFEAED-1C9E-4DDE-8054-FE48576CED3D")!,
                name: "Error-log: laatste X regels",
                template: "sudo tail -{{regels:10}} /var/log/httpd/domains/{{domein:voorbeeld.nl}}.error.log",
                category: "Logs", tags: ["errorlog"]),
        Snippet(id: UUID(uuidString: "B05533F9-D6B7-4549-863E-04AED9CC0292")!,
                name: "Usage-log: zoeken op tekst",
                template: "sudo grep '{{zoekterm:POST}}' /var/log/httpd/domains/{{domein:voorbeeld.nl}}.log",
                category: "Logs", tags: ["usagelog"]),
        Snippet(id: UUID(uuidString: "7EB4E09C-0DF6-45BA-9089-C3D4E3C0092D")!,
                name: "Usage-log: laatste X regels",
                template: "sudo tail -{{regels:20}} /var/log/httpd/domains/{{domein:voorbeeld.nl}}.log",
                category: "Logs", tags: ["usagelog"]),
        Snippet(id: UUID(uuidString: "F4BB4832-D583-44FF-9BAE-B1A94E5C8B80")!,
                name: "FTP auth-log doorzoeken",
                template: "sudo grep {{debuser:deb1234}} /var/log/proftpd/auth.log",
                category: "Logs", tags: ["ftp", "log"]),
        Snippet(id: UUID(uuidString: "BAEA12A7-0780-4BE4-A58B-6C20228F1B39")!,
                name: "FTP access-log doorzoeken (archief)",
                template: "sudo zgrep {{debuser:deb1234}} /var/log/proftpd/access.log-{{datum:20200202}}.gz",
                category: "Logs", tags: ["ftp", "log"]),
        Snippet(id: UUID(uuidString: "64B9BC1B-652B-4964-B882-849E0C627238")!,
                name: "Mail-log zoeken op ID",
                template: #"sudo zgrep "{{mail_id}}" /var/log/exim/main.log"#,
                category: "Logs", tags: ["mail", "exim"]),
        Snippet(id: UUID(uuidString: "FF806CAC-054A-44CE-9D68-DD0E0B30AD92")!,
                name: "Mail-log zoeken op e-mailadres",
                template: #"sudo zgrep "{{emailadres:info@voorbeeld.nl}}" /var/log/exim/main.log"#,
                category: "Logs", tags: ["mail", "exim"]),
        Snippet(id: UUID(uuidString: "9B18C30F-25AA-43B4-830B-C1C1D3978B88")!,
                name: "Beschikbare mail-logs tonen",
                template: "ls /var/log/exim/",
                category: "Logs", tags: ["mail", "exim"]),
        Snippet(id: UUID(uuidString: "D0187A85-B5BE-4D54-9EA3-D864B9033BC8")!,
                name: "Mail-log zoeken op e-mailadres (oudere log)",
                template: #"sudo zgrep "{{emailadres:info@voorbeeld.nl}}" /var/log/exim/mainlog-{{datum:20200708}}.gz"#,
                category: "Logs", tags: ["mail", "exim"]),
        Snippet(id: UUID(uuidString: "B82DA44B-DA84-421A-9FC6-972E9555BCA6")!,
                name: "Authenticatie-log doorzoeken (dovecot, huidig)",
                template: "sudo zgrep '{{emailadres:info@voorbeeld.nl}}' /var/log/dovecot.log",
                category: "Logs", tags: ["mail", "dovecot"]),
        Snippet(id: UUID(uuidString: "72960AB8-5937-49DE-AEBA-BE550412C824")!,
                name: "Authenticatie-log doorzoeken (dovecot, alle)",
                template: "sudo zgrep '{{emailadres:info@voorbeeld.nl}}' /var/log/dovecot.log*",
                category: "Logs", tags: ["mail", "dovecot"]),
        Snippet(id: UUID(uuidString: "20FEFAFD-AE68-4CC4-BE98-83CD18DC6882")!,
                name: "Gebounced e-mailadressen achterhalen",
                template: "sudo grep {{emailadres:deb1234@voorbeeld.nl}} /var/log/exim/main.log | grep Unrouteable | awk '{ print $5 }' | uniq",
                category: "Logs", tags: ["mail", "bounce"]),
        Snippet(id: UUID(uuidString: "815C9B0A-9E3A-4088-991E-74E8868805A7")!,
                name: "Entry-processes inzien",
                template: "sudo ls /var/www/html/snapshot/apache",
                category: "Logs", tags: ["entry-processes"]),
        Snippet(id: UUID(uuidString: "19796399-D511-4462-BB62-2D5281C64AAF")!,
                name: "Let's Encrypt validatie-checks bekijken",
                template: "sudo zgrep '{{domein:voorbeeld.nl}}' /var/log/admingonist/admingonist-certificates-retry.log",
                category: "Logs", tags: ["ssl", "letsencrypt", "certificaat"]),

        // ── Firewall ────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "5712F5EA-2043-4043-B469-834EC8283DDF")!,
                name: "IP-adres opzoeken (vandaag)",
                template: "sudo journalctl --since today | grep {{ip}}",
                category: "Firewall", tags: ["firewall", "ip"]),
        Snippet(id: UUID(uuidString: "9818317F-DD68-4899-8AAB-7DA8DD0DA8BD")!,
                name: "IP-adres opzoeken (gisteren)",
                template: "sudo journalctl --since yesterday | grep {{ip}}",
                category: "Firewall", tags: ["firewall", "ip"]),
        Snippet(id: UUID(uuidString: "DF8CA162-AF00-4486-BE67-A4AB01BCCA98")!,
                name: "IP-adres opzoeken (afgelopen uur)",
                template: #"sudo journalctl --since "1 hour ago" | grep {{ip}}"#,
                category: "Firewall", tags: ["firewall", "ip"]),
        Snippet(id: UUID(uuidString: "995B228C-76A7-45B0-8A8F-2479DAED0D09")!,
                name: "IP-adres opzoeken (afgelopen 2 dagen)",
                template: #"sudo journalctl --since "2 days ago" | grep {{ip}}"#,
                category: "Firewall", tags: ["firewall", "ip"]),
        Snippet(id: UUID(uuidString: "52E5E072-64D8-4C08-9BA5-FEF9CBB057E2")!,
                name: "IP-adres opzoeken (tussen X en Y uur geleden)",
                template: #"sudo journalctl --since "{{van:3 hours ago}}" --until "{{tot:2 hours ago}}" | grep {{ip}}"#,
                category: "Firewall", tags: ["firewall", "ip"]),
        Snippet(id: UUID(uuidString: "AB0E1455-E0F1-45D5-AD3B-66C5AB15C9B0")!,
                name: "IP-adres opzoeken (tussen data)",
                template: #"sudo journalctl --since "{{van:2024-06-26}}" --until "{{tot:2024-06-29}}" | grep {{ip}}"#,
                category: "Firewall", tags: ["firewall", "ip"]),
        Snippet(id: UUID(uuidString: "CEED0FFA-4CE5-4B17-B1E1-4E76742D08B2")!,
                name: "IP-adres opzoeken (tussen tijdstippen)",
                template: #"sudo journalctl --since "{{van:2024-06-26 23:15:00}}" --until "{{tot:2024-06-26 23:20:00}}" | grep {{ip}}"#,
                category: "Firewall", tags: ["firewall", "ip"]),
        Snippet(id: UUID(uuidString: "EF15A3C5-406D-4A79-B022-CD9A883C1CA9")!,
                name: "IP-adres opzoeken (max X resultaten)",
                template: "sudo journalctl --since today -n {{aantal:50}} | grep {{ip}}",
                category: "Firewall", tags: ["firewall", "ip"]),
        Snippet(id: UUID(uuidString: "6DD62B32-3EE9-417C-AF8B-DDBE466BDC0B")!,
                name: "Controleren of IP in firewall staat",
                template: "sudo csf -g {{ip}}",
                category: "Firewall", tags: ["firewall", "csf"]),
        Snippet(id: UUID(uuidString: "18262A0E-ED09-4BC3-BD2D-9AE7DFF54344")!,
                name: "IP-adres uit firewall halen",
                template: "sudo csf -tr {{ip}}",
                category: "Firewall", tags: ["firewall", "csf"]),

        // ── Hostingpakket ───────────────────────────────────────────
        Snippet(id: UUID(uuidString: "121CE814-5DD6-407F-AAFC-F198F1178A84")!,
                name: "Omzetten naar static HTML",
                template: "sudo antasupport static_html {{debuser:deb12345}} {{domein:voorbeeld.nl}}",
                category: "Hostingpakket", tags: ["static-html"]),
        Snippet(id: UUID(uuidString: "DCAA49FE-3E1B-4C2B-BFDF-92F1435EA678")!,
                name: "Hostingpakket herstarten (cage remount)",
                template: "sudo antasupport remount_cage {{debuser:deb12345}}",
                category: "Hostingpakket", tags: ["remount"]),
        Snippet(id: UUID(uuidString: "7C2C466B-AE28-4303-8F75-072DB7BC392C")!,
                name: "PHP-processen killen (voor klant)", template: "/usr/bin/pkill lsphp",
                category: "Hostingpakket", cage: true, tags: ["php"]),
        Snippet(id: UUID(uuidString: "8BDACF4F-3807-4458-9049-421F9B54A1B5")!,
                name: "'Domain already exists': DA-configuratiebestanden zoeken",
                template: "sudo ls /usr/local/directadmin/data/users/{{debuser:deb12345}}/domains/",
                category: "Hostingpakket", tags: ["domain-exists"]),
        Snippet(id: UUID(uuidString: "1AE870E6-26C6-4B89-9664-BDDAF482DAD6")!,
                name: "'Domain already exists': domein in /etc/virtual/domains zoeken",
                template: "sudo cat /etc/virtual/domains | grep {{domein:voorbeeld.nl}}",
                category: "Hostingpakket", tags: ["domain-exists"]),
        Snippet(id: UUID(uuidString: "57E8DAD9-AB3F-4C41-8EC2-4C76054ACF5B")!,
                name: "'Domain already exists': eigenaar zoeken in domainowners",
                template: "sudo cat /etc/virtual/domainowners | grep {{domein:voorbeeld.nl}}",
                category: "Hostingpakket", tags: ["domain-exists"]),
        Snippet(id: UUID(uuidString: "F905A300-6A25-4B87-92B2-82482C1399DF")!,
                name: "'Domain already exists': mail-configuratie bekijken",
                template: "sudo ls /etc/virtual/{{domein:voorbeeld.nl}}",
                category: "Hostingpakket", tags: ["domain-exists"]),
        Snippet(id: UUID(uuidString: "1E9CAB73-5834-4B6C-887F-C7A1428FD561")!,
                name: "'Domain already exists': domeinmap nog aanwezig checken",
                template: "sudo ls /home/{{debuser:deb12345}}/domains/",
                category: "Hostingpakket", tags: ["domain-exists"]),

        // ── Backup transfer ─────────────────────────────────────────
        Snippet(id: UUID(uuidString: "6A366C2C-87AF-44BD-B825-06FACEE2F30F")!,
                name: "Backup transfer (met deb-wachtwoord)",
                template: "sudo /usr/local/bin/antasupport transferbackup {{bron_account:deb1234}} {{doel_account:deb5678}} {{doel_server:s160.webhostingserver.nl}} {{backup_bestand:backup-Jun-12-2020-3.tar.gz}}",
                category: "Backup transfer", tags: ["backup"]),
        Snippet(id: UUID(uuidString: "F6A0F643-3135-4FEA-AB29-CEAE756484FB")!,
                name: "Backup transfer (met FTP-account)",
                template: "sudo /usr/local/bin/antasupport transferbackup --ftp_user {{ftp_email:antaftp@voorbeeld.nl}} {{bron_account:deb1234}} {{doel_account:deb5678}} {{doel_server:s160.webhostingserver.nl}} {{backup_bestand:backup-Jun-12-2020-3.tar.gz}}",
                category: "Backup transfer", tags: ["backup", "ftp"]),

        // ── DNS ─────────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "875F8FD1-5964-425B-8693-E177EB665269")!,
                name: "DNS-zone opvragen",
                template: "sudo cat /var/named/{{domein:voorbeeld.nl}}.db",
                category: "DNS", tags: ["dns"]),
        Snippet(id: UUID(uuidString: "725571A7-6A93-483C-8219-BF9ABD827807")!,
                name: "DNS-zone opvragen uit snapshot",
                template: "sudo cat /userdata/root-fs/.zfs/snapshot/{{snapshot:antabackup_24hour-2017-01-12-2303}}/var/named/{{domein:voorbeeld.nl}}.db",
                category: "DNS", tags: ["dns", "snapshot"]),
        Snippet(id: UUID(uuidString: "C69A487B-6CFD-4034-95A5-74AD5C3235F3")!,
                name: "Dig - DNS-record opzoeken",
                template: "dig {{nameserver:choice:Globaal=|webhostingserver.g1-dns.one=@webhostingserver.g1-dns.one|webhostingserver.g1-dns.com=@webhostingserver.g1-dns.com}} {{domein:voorbeeld.nl}} {{type:choice:A|AAAA|MX|TXT|NS|CNAME|SOA|PTR|ANY}}",
                category: "DNS", tags: ["dns", "dig"]),

        // ── Snapshots ───────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "9A703FE5-07EE-4376-9401-F3D83CB04D62")!,
                name: "Recente snapshots tonen",
                template: "sudo ls -alh /home/.zfs/snapshot/",
                category: "Snapshots", tags: ["snapshot"]),
        Snippet(id: UUID(uuidString: "F2E9AFA6-BE35-48FE-8286-448B7631294F")!,
                name: "Oudere snapshots tonen",
                template: "sudo ls -alh /backups/mount/userdata/home/.zfs/snapshot/",
                category: "Snapshots", tags: ["snapshot"]),
        Snippet(id: UUID(uuidString: "712791E5-3E0C-4EE4-BB9A-FDADAF594A3D")!,
                name: "Snapshot: domains-map bekijken (recent)",
                template: "sudo ls -alh /home/.zfs/snapshot/{{snapshot}}/{{debuser:deb12345}}/domains/",
                category: "Snapshots", tags: ["snapshot"]),
        Snippet(id: UUID(uuidString: "45C53C50-1B88-4F9E-B224-8A7A31AA4D7F")!,
                name: "Snapshot: public_html bekijken (recent)",
                template: "sudo ls -alh /home/.zfs/snapshot/{{snapshot}}/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html",
                category: "Snapshots", tags: ["snapshot"]),
        Snippet(id: UUID(uuidString: "1A2341B2-A37A-4FDD-9531-0F9AFE60F27A")!,
                name: "Snapshot: domains-map bekijken (ouder)",
                template: "sudo ls -alh /backups/mount/userdata/home/.zfs/snapshot/{{snapshot}}/{{debuser:deb12345}}/domains",
                category: "Snapshots", tags: ["snapshot"]),
        Snippet(id: UUID(uuidString: "55E78A87-269B-4C84-8A71-B9F7FA633061")!,
                name: "Snapshot: public_html bekijken (ouder)",
                template: "sudo ls -alh /backups/mount/userdata/home/.zfs/snapshot/{{snapshot}}/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html",
                category: "Snapshots", tags: ["snapshot"]),
        Snippet(id: UUID(uuidString: "CBBF5DA8-6637-4A63-8598-84B4A32C3A10")!,
                name: "Snapshot: bestand uitlezen (recent)",
                template: "sudo cat /home/.zfs/snapshot/{{snapshot}}/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html/{{bestand:index.php}}",
                category: "Snapshots", tags: ["snapshot"]),
        Snippet(id: UUID(uuidString: "7B448770-6099-49E9-A19D-FC2F84AFF75C")!,
                name: "Snapshot: bestand uitlezen (ouder)",
                template: "sudo cat /backups/mount/userdata/root-fs/.zfs/snapshot/{{snapshot}}/usr/home/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html/{{bestand:index.php}}",
                category: "Snapshots", tags: ["snapshot"]),

        // ── Bestandsrechten ─────────────────────────────────────────
        Snippet(id: UUID(uuidString: "20105033-3166-4E36-A37F-31563E8D4D18")!,
                name: "Bestandsrechten herstellen (644/755)", template: """
                cd /home/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html/
                find . -type f -exec chmod 644 {} \\;
                find . -type d -exec chmod 755 {} \\;
                """,
                category: "Bestandsrechten", cage: true, tags: ["chmod", "permissions"]),

        // ── Database ────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "78B2D97F-2C4A-47B6-B715-37E4A2BC4359")!,
                name: "Database importeren via SSH", template: """
                cd /home/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html/
                mysql -u {{db_gebruiker}} -p {{db_naam}} < {{sql_bestand:export.sql}}
                """,
                category: "Database", cage: true, tags: ["mysql", "import"]),

        // ── Bot-traffic ─────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "A30C3795-7C35-40B7-9163-F86473271AEB")!,
                name: "Bots vs. verkeer tellen (huidige log, op server)", template:
                #"domain='{{domein}}' && bots='Mediapartners-Google|AwarioBot|AdsTxtCrawler|Slackbot|Slack-ImgProxy|FeedBurner|FriendlyCrawler|GeedoProductSearch|PetalBot|DataForSeoBot|LinkedInBot|ClaudeBot|claudebot|omgili.com|anthropic-ai|Google-Extended|GPTBot|ChatGPT-User|CCBot|ImagesiftBot|serpstrabot|Amazonbot|Googlebot|bingbot|DotBot|AhrefsBot|SemRushBot|YandexBot|bytedance|SeekportBot|LaMetric|Barkrowler|MJ12bot|BLEXBot|SiteAuditBot|SentiBot|ZoominfoBot|AdsBot-Google|DynatraceSynthetic|GTranslate-Translation-Proxy|Applebot|Screaming Frog SEO Spider|(dart:io)|Verity|aiohttp|FacebookBot|facebookexternalhit|meta-externalagent|meta-externalfetcher|facebookcatalog|InternetMeasurement|DuckDuckBot'; readarray -d '|' -t search_bots < <(printf "%s" "$bots"); declare -p search_bots; declare -A found_bots; all_bots=0; if [ "$(sudo cat /var/log/httpd/domains/${domain}.log 2>/dev/null |wc -l)" -lt 1 ]; then printf "\n\n========================================\n\n$(tput bold)⚠ No results found for:\t${domain} ⚠$(tput sgr0)\n\nLogfile doesn't exist: \t/var/log/httpd/domains/${domain}.log\n\n========================================\n\n\n"; else printf "\n========================================\n\n$(tput bold)Results for: ${domain}$(tput sgr0)\nDate/time: $(date)\n\n" && printf "=====\n\n"; for ((b = 0; b < ${#search_bots[@]}; b++)); do cur_bot=${search_bots[$b]}; num_bot=$(sudo zgrep -E "${cur_bot}" /var/log/httpd/domains/${domain}.log |wc -l); if [ $num_bot -gt 0 ]; then printf "%-40s %-10s\n" "- $(tput bold)$cur_bot$(tput sgr0)" "$num_bot"; all_bots=$(($all_bots+$num_bot)); fi; done; printf "\n=====\n\n" && all_lines=$(sudo cat /var/log/httpd/domains/${domain}.log |wc -l) && without_bots=$(($all_lines-$all_bots)) && printf "• $(tput bold)Bots:$(tput sgr0) ${all_bots}\n• $(tput bold)Not bots$(tput sgr0): ${without_bots}\n• $(tput bold)Total$(tput sgr0): ${all_lines}\n\n========================================\n\n"; fi;"#,
                category: "Bot-traffic", tags: ["bots", "logs"]),
        Snippet(id: UUID(uuidString: "BFB76A0B-8D81-409F-8B42-D2BE99675215")!,
                name: "Bots vs. verkeer tellen (oudere log .tar.gz)", template: #"""
                domain='{{domein}}' && ARCHIVE_LOG_FILE='{{archief:Jul-2024.tar.gz}}';
                bots='Mediapartners-Google|AwarioBot|AdsTxtCrawler|Slackbot|Slack-ImgProxy|FeedBurner|FriendlyCrawler|GeedoProductSearch|PetalBot|DataForSeoBot|LinkedInBot|ClaudeBot|claudebot|omgili.com|anthropic-ai|Google-Extended|GPTBot|ChatGPT-User|CCBot|ImagesiftBot|serpstrabot|Amazonbot|Googlebot|bingbot|DotBot|AhrefsBot|SemRushBot|YandexBot|bytedance|SeekportBot|LaMetric|Barkrowler|MJ12bot|BLEXBot|SiteAuditBot|SentiBot|ZoominfoBot|AdsBot-Google|DynatraceSynthetic|GTranslate-Translation-Proxy|Applebot|Screaming Frog SEO Spider|(dart:io)|Verity|aiohttp|FacebookBot|facebookexternalhit|meta-externalagent|meta-externalfetcher|facebookcatalog|InternetMeasurement|DuckDuckBot'; readarray '|' search_bots <<<"$bots"; declare -p search_bots; declare -A found_bots; all_bots=0; if [[ ! -f "/home/$(whoami)/domains/${domain}/logs/${ARCHIVE_LOG_FILE}" ]]; then printf "\n\n========================================\n\n$(tput bold)⚠ No results found for:\t${domain} ⚠$(tput sgr0)\n\nArchive doesn't exist: \t/home/$(whoami)/domains/${domain}/logs/${ARCHIVE_LOG_FILE}\n\n========================================\n\n\n"; else printf "\n========================================\n\n$(tput bold)Results for: ${domain}$(tput sgr0)\nArchive: ${ARCHIVE_LOG_FILE}\n\n" && printf "=====\n\n"; logfile="usage-log.txt"; tar -zxvf /home/$(whoami)/domains/${domain}/logs/${ARCHIVE_LOG_FILE} "${domain}.log.1"; mv "${domain}.log.1" ${logfile}; for ((b = 0; b < ${#search_bots[@]}; b++)); do cur_bot=${search_bots[$b]::-1}; num_bot=$(grep -E "${cur_bot}" ${logfile} |wc -l); if [ $num_bot -gt 0 ]; then printf "%-40s %-10s\n" "- $(tput bold)$cur_bot$(tput sgr0)" "$num_bot"; all_bots=$(($all_bots+$num_bot)); fi; done; printf "\n=====\n\n" && all_lines=$(cat /home/$(whoami)/domains/${domain}/logs/${logfile} |wc -l) && without_bots=$(($all_lines-$all_bots)) && printf "• $(tput bold)Bots:$(tput sgr0) ${all_bots}\n• $(tput bold)Not bots$(tput sgr0): ${without_bots}\n• $(tput bold)Total$(tput sgr0): ${all_lines}\n\n========================================\n\n"; fi; rm -rf /home/$(whoami)/domains/${domain}/logs/${logfile};
                """#,
                category: "Bot-traffic", cage: true, tags: ["bots", "logs"]),

        // ── Systeem ─────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "1094AA99-B9C9-424B-9516-E384BD9C4AFD")!,
                name: "Aantal domein-mappen tellen",
                template: #"echo "Aantal domeinen: " $(sudo ls /home/{{debuser:deb12345}}/domains/ | wc -l);"#,
                category: "Systeem", tags: ["count"]),
        Snippet(id: UUID(uuidString: "46BD469E-C354-438D-A22D-A6DCD7C4FE0F")!,
                name: "Aantal bestanden tellen in map",
                template: "find /home/{{debuser:deb12345}}/domains/{{domein:voorbeeld.nl}}/public_html/{{map}} | wc -l",
                category: "Systeem", cage: true, tags: ["inodes", "count"]),
        Snippet(id: UUID(uuidString: "5730BC34-8001-4E84-9A42-59C9AED88059")!,
                name: "Bestanden tellen per map (huidige map)",
                template: "du -a | cut -d/ -f2 | sort | uniq -c | sort -nr",
                category: "Systeem", cage: true, tags: ["inodes", "count"]),
        Snippet(id: UUID(uuidString: "C542DA16-4CAC-4284-8D86-962F597C8194")!,
                name: "Inode-gebruik per map (detail + totaal)",
                template: #"echo "Detailed Inode usage for: $(pwd)" ; for d in `find -maxdepth 1 -type d |cut -d\/ -f2 |grep -xv . |sort`; do c=$(find $d |wc -l) ; printf " - $d: \t\t$c \n" ; done ; printf "Totaal inodes: \t\t$(find $(pwd) | wc -l)\n""#,
                category: "Systeem", cage: true, tags: ["inodes", "count", "script"]),

        // ── Screen & Tmux ───────────────────────────────────────────
        Snippet(id: UUID(uuidString: "11818E11-BA15-4DDA-B133-7C084F67219C")!,
                name: "Screen sessie starten",
                template: "screen -S {{sessienaam}}",
                category: "Screen & Tmux", tags: ["screen"]),
        Snippet(id: UUID(uuidString: "4689D91F-FF63-4557-BA8E-E980900B92DF")!,
                name: "Screen sessies tonen",
                template: "screen -ls",
                category: "Screen & Tmux", tags: ["screen"]),
        Snippet(id: UUID(uuidString: "EE61C375-DAEA-472E-8F38-1609940D3F61")!,
                name: "Screen sessie hervatten",
                template: "screen -x {{sessie_id}}",
                category: "Screen & Tmux", tags: ["screen"]),
        Snippet(id: UUID(uuidString: "C7140A8A-FBAB-4926-83C0-78640FBBCB9D")!,
                name: "Tmux starten",
                template: "tmux",
                category: "Screen & Tmux", tags: ["tmux"]),
        Snippet(id: UUID(uuidString: "39CDE70C-4A76-4EF0-ABFB-427CD6407121")!,
                name: "Tmux hervatten (attach)",
                template: "tmux attach",
                category: "Screen & Tmux", tags: ["tmux"]),

        // ── Reseller ────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "23CD1926-546F-456D-BFF1-2BDD5954E722")!,
                name: "Beschikbare snapshots tonen (DirectAdmin, recent)",
                template: "sudo ls /usr/local/directadmin/.zfs/snapshot/",
                category: "Reseller", tags: ["reseller", "snapshot"]),
        Snippet(id: UUID(uuidString: "401FAEC8-8D8F-4171-A6DC-7E9A680B32A8")!,
                name: "Users + domeinen uit snapshot achterhalen (recent, script)", template: """
                BACKUP_TO_CHECK='{{snapshot:antabackup_Xhour-YYYY-MM-DD-HHSS}}'
                DEB_RESELLER='{{deb_reseller:debXXXXXX}}'

                reseller_users=$(sudo cat /usr/local/directadmin/.zfs/snapshot/${BACKUP_TO_CHECK}/data/users/${DEB_RESELLER}/users.list);

                for USER in ${reseller_users[@]}
                do
                    echo "User: " $USER " > " $(sudo cat /usr/local/directadmin/.zfs/snapshot/${BACKUP_TO_CHECK}/data/users/$USER/domains.list)
                done
                """,
                category: "Reseller", tags: ["reseller", "snapshot", "script"]),
        Snippet(id: UUID(uuidString: "ACA32FB7-E6B7-4154-BAA7-A5B1FF383636")!,
                name: "Losstaande domeinen van reseller (recent)",
                template: "sudo cat /usr/local/directadmin/.zfs/snapshot/{{snapshot:antabackup_Xhour-YYYY-MM-DD-HHSS}}/data/users/{{deb_reseller:debXXXXXX}}/domains.list",
                category: "Reseller", tags: ["reseller", "snapshot"]),
        Snippet(id: UUID(uuidString: "D06BE97E-CF57-4E29-BCD2-472B49C8D155")!,
                name: "Beschikbare snapshots tonen (DirectAdmin, ouder)",
                template: "sudo ls /backups/mount/userdata/usr-local-directadmin/.zfs/snapshot/",
                category: "Reseller", tags: ["reseller", "snapshot"]),
        Snippet(id: UUID(uuidString: "0638AF44-0CF0-4FD8-849C-646AAE784DD3")!,
                name: "Users + domeinen uit snapshot achterhalen (ouder, script)", template: """
                BACKUP_TO_CHECK='{{snapshot:antabackup_Xhour-YYYY-MM-DD-HHSS}}'
                DEB_RESELLER='{{deb_reseller:debXXXXXX}}'

                reseller_users=$(sudo cat /backups/mount/userdata/usr-local-directadmin/.zfs/snapshot/${BACKUP_TO_CHECK}/data/users/${DEB_RESELLER}/users.list);

                for USER in ${reseller_users[@]}
                do
                    echo "User: " $USER " > " $(sudo cat /backups/mount/userdata/usr-local-directadmin/.zfs/snapshot/${BACKUP_TO_CHECK}/data/users/$USER/domains.list)
                done
                """,
                category: "Reseller", tags: ["reseller", "snapshot", "script"]),
        Snippet(id: UUID(uuidString: "9A2BB617-0A77-47AA-AF52-BA8D07BF8592")!,
                name: "Losstaande domeinen van reseller (ouder)",
                template: "sudo cat /backups/mount/userdata/usr-local-directadmin/.zfs/snapshot/{{snapshot:antabackup_Xhour-YYYY-MM-DD-HHSS}}/data/users/{{deb_reseller:debXXXXXX}}/domains.list",
                category: "Reseller", tags: ["reseller", "snapshot"]),

        // ── Redis ───────────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "CC854BFC-6710-49FE-89AB-AAF1F2486AD9")!,
                name: "Redis-cli openen",
                template: "redis-cli -s /tmp/redis.sock",
                category: "Redis", cage: true, tags: ["redis"]),
        Snippet(id: UUID(uuidString: "15A7DC0A-3AE3-4989-AC60-CB30ADC2D770")!,
                name: "Redis: alle databases flushen",
                template: "redis-cli -s /tmp/redis.sock FLUSHALL",
                category: "Redis", cage: true, tags: ["redis", "flush"]),
        Snippet(id: UUID(uuidString: "5FF77F02-6174-4A28-A63A-EBCBED8F118A")!,
                name: "Redis: specifieke database flushen",
                template: "redis-cli -n {{database_nummer}} -s /tmp/redis.sock FLUSHDB",
                category: "Redis", cage: true, tags: ["redis", "flush"]),

        // ── Nextcloud ───────────────────────────────────────────────
        Snippet(id: UUID(uuidString: "3368B2A4-57A1-46C1-B333-811789847DB7")!,
                name: "Prullenbak legen (alle gebruikers)", template: """
                cd /home/*/domains/*/public_html/
                php -d memory_limit=512M occ trashbin:cleanup --all-users
                """,
                category: "Nextcloud", cage: true, tags: ["nextcloud", "trashbin"]),
        Snippet(id: UUID(uuidString: "1BC6A616-1F64-4938-B961-C8D676BF5535")!,
                name: "Prullenbak legen (specifieke gebruiker)", template: """
                cd /home/*/domains/*/public_html/
                php -d memory_limit=512M occ trashbin:cleanup {{nextcloud_gebruiker}}
                """,
                category: "Nextcloud", cage: true, tags: ["nextcloud", "trashbin"]),
        Snippet(id: UUID(uuidString: "67D706AB-8373-4FA6-B87D-8D668F0C4809")!,
                name: "File locks weghalen", template: """
                cd /home/*/domains/*/public_html/
                php -d memory_limit=512M occ maintenance:mode --on
                redis-cli -s /tmp/redis.sock FLUSHALL
                php -d memory_limit=512M occ maintenance:mode --off
                php -d memory_limit=512M occ files:scan --all
                """,
                category: "Nextcloud", cage: true, tags: ["nextcloud", "locks"]),
        Snippet(id: UUID(uuidString: "71714805-6994-421D-A3D2-346551922355")!,
                name: "Uit onderhoudsmodus halen", template: """
                cd /home/*/domains/*/public_html/
                php -d memory_limit=512M occ maintenance:mode --off
                """,
                category: "Nextcloud", cage: true, tags: ["nextcloud", "maintenance"]),
        Snippet(id: UUID(uuidString: "F7D55593-5CF6-44DE-90B0-C64939D3B12F")!,
                name: "Preview-map legen (nieuwere Nextcloud)",
                template: "rm -rf /home/{{debuser:deb12345}}/domains/{{domein:opsXXXXXX.antagonist.cloud}}/public_html/data/appdata_{{hash}}/preview/*",
                category: "Nextcloud", cage: true, tags: ["nextcloud", "preview", "inodes"]),
        Snippet(id: UUID(uuidString: "E9A92638-710B-41DB-9FBB-83CB1E42C490")!,
                name: "Preview-map legen (oudere Nextcloud)",
                template: "rm -rf /home/{{debuser:deb12345}}/domains/{{domein:opsXXXXXX.antagonist.cloud}}/public_html/.{{hash}}.data/appdata_oc{{hash}}/preview/*",
                category: "Nextcloud", cage: true, tags: ["nextcloud", "preview", "inodes"]),
        Snippet(id: UUID(uuidString: "F97D2D99-DD75-4E84-AA20-CBF2780840F0")!,
                name: "App-data opnieuw scannen (occ)",
                template: "php -d memory_limit=512M occ files:scan-app-data",
                category: "Nextcloud", cage: true, tags: ["nextcloud", "scan"]),
        Snippet(id: UUID(uuidString: "5AC51F36-9DF1-4C25-AE12-602F465AE624")!,
                name: "Alle bestanden opnieuw scannen (occ)",
                template: "php -d memory_limit=512M occ files:scan --all",
                category: "Nextcloud", cage: true, tags: ["nextcloud", "scan"]),
        Snippet(id: UUID(uuidString: "3FDDF101-E356-4FCD-97F7-F394CB1DBB8B")!,
                name: "Bestanden met datum 1970 zoeken",
                template: #"find $(pwd) -type f -name "*" -newermt 1970-01-01 ! -newermt 1970-01-02"#,
                category: "Nextcloud", cage: true, tags: ["nextcloud", "1970"]),
        Snippet(id: UUID(uuidString: "429D46D7-1821-4A53-9CC4-DF2ACD942F2D")!,
                name: "Bestanden met datum 1970 tellen",
                template: #"find $(pwd) -type f -name "*" -newermt 1970-01-01 ! -newermt 1970-01-02 | wc -l"#,
                category: "Nextcloud", cage: true, tags: ["nextcloud", "1970"]),
        Snippet(id: UUID(uuidString: "D2A3A649-D4E7-42E8-AA11-4747F3D34A89")!,
                name: "Nextcloud-log bekijken (laatste X regels)",
                template: "tail -{{regels:20}} /home/{{debuser:deb12345}}/domains/{{domein:opsXXXXXX.antagonist.cloud}}/public_html/data/nextcloud.log",
                category: "Nextcloud", cage: true, tags: ["nextcloud", "log"]),
        Snippet(id: UUID(uuidString: "FDD49F6A-23C7-4B82-B799-1994C9C1CF5B")!,
                name: "Bestandsversies opruimen (alle gebruikers)",
                template: "php -d memory_limit=512M occ version:cleanup",
                category: "Nextcloud", cage: true, tags: ["nextcloud", "versions"]),
        Snippet(id: UUID(uuidString: "4D4559F8-9E9D-4A6B-9AEB-7F00F330CFA1")!,
                name: "Bestandsversies opruimen (specifieke gebruiker(s))",
                template: "php -d memory_limit=512M occ versions:cleanup {{nextcloud_gebruikers}}",
                category: "Nextcloud", cage: true, tags: ["nextcloud", "versions"]),
        Snippet(id: UUID(uuidString: "F57334B7-DCF1-4566-B119-BF5E90C1F55C")!,
                name: "occ executable maken ('occ: opdracht niet gevonden')",
                template: "chmod +x occ",
                category: "Nextcloud", cage: true, tags: ["nextcloud", "occ"]),
    ]
}
