## **SNORT Installation**

Run Commands as Sudo
```bash
    #if only su (without -) it won't pass the path
    su -
```

Downloadand install the Snort intrusion detection system with support for the “nfq” DAQ
```sh
# Install required packages (additional packages may be required for your system)
apt install libpcap-dev  libpcre2-dev  libdnet-dev  libdnet  libnetfilter-queue1 libnetfilter-queue-dev  zlib1g-dev  build-essential  flex  bison  libdumbnet-dev libdumbnet1 libpcre++-dev luajit libluajit-5.1-dev libssl-dev
# Download required sources for libdaq and Snort 2
cd /usr/local/src
wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz
wget https://www.snort.org/downloads/snort/snort-2.9.19.tar.gz
# Compile and install libdaq with support for the “nfq” DAQ
tar zxvf daq-2.0.7.tar.gz
cd daq-2.0.7
# As the result of the following command you should make sure that the “nfq”
# module is enabled for compilation
./configure --enable-sourcefire --enable-nfq
# Compile and install DAQ
make
make install
# Note the DAQ library is installed on/usr/local/lib/daq
# - Installed DAQs are available in /usr/local/lib/daq
# - To enable the usage of the compiled modules, add the line “/usr/local/lib/daq” 
# to /etc/ld.so.conf and run “ldconfig”
echo """
include /etc/ld.so.conf.d/*.conf
/usr/local/lib/daq
""" > /etc/ld.so.conf
sudo ldconfig
# Configure Snort for compilation
cd /usr/local/src
tar zxvf snort-2.9.19.tar.gz
cd snort-2.9.19
./configure --enable-sourcefire--with-daq-includes=/usr/local/lib --with-daq-libraries=/usr/local/lib --prefix=/usr/local/snort
# Compile and install Snort
make
make install
ln -s /usr/local/snort/bin/snort /usr/sbin/snort
# Set up the initial configuration of Snort
cp -R /usr/local/src/snort-2.9.19/etc/ /etc/snort
# Please note:
# -To verify if Snort is available: 
#   /usr/sbin/snort -v 
# If no errors occur, this instruction places snort running in sniffer mode
# You can stop snort execution with the keys: Ctrl + C.
# - To check the available DAQs: 
/usr/sbin/snort --daq-list
# Create folders and files that are required for Snort 
mkdir /etc/snort/rules
mkdir /etc/snort/preproc_rules
mkdir /usr/local/lib/snort_dynamicpreprocessor
mkdir /usr/local/lib/snort_dynamicrules
mkdir /usr/local/lib/snort_dynamicengine
# Create necessary files
touch /etc/snort/rules/white_list.rules
touch /etc/snort/rules/black_list.rules
# Copy necessary files for dynamic pre processors 
cp /usr/local/src/snort-2.9.19/src/dynamic-plugins/sf_engine/.libs/libsf_engine.* /usr/local/lib/snort_dynamicengine/
cp /usr/local/src/snort-2.9.19/src/dynamic-preprocessors/build/usr/local/snort/lib/snort_dynamicpreprocessor/* /usr/local/lib/snort_dynamicpreprocessor/
# The  default  snort.conf  file  contains configurations which  might  not  be  required,  the  first  step  is  to deactivate them.
# Deactivate rule files
sudo sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf
# Configure the internal networks that need to be protected. 
echo """
###################################################
# Step #1: Set the network variables.  For more information, see README.variables
###################################################
ipvar HOME_NET [10.10.10.0/24,10.20.20.0/24]
ipvar EXTERNAL_NET any
ipvar DNS_SERVERS \$HOME_NET
ipvar SMTP_SERVERS \$HOME_NET
ipvar HTTP_SERVERS \$HOME_NET
ipvar SQL_SERVERS \$HOME_NET
ipvar TELNET_SERVERS \$HOME_NET
ipvar SSH_SERVERS \$HOME_NET
ipvar FTP_SERVERS \$HOME_NET
ipvar SIP_SERVERS \$HOME_NET
portvar HTTP_PORTS [80,81,311,383,591,593,901,1220,1414,1741,1830,2301,2381,2809,3037,3128,3702,4343,4848,5250,6988,7000,7001,7144,7145,7510,7777,7779,8000,8008,8014,8028,8080,8085,8088,8090,8118,8123,8180,8181,8243,8280,8300,8800,8888,8899,9000,9060,9080,9090,9091,9443,9999,11371,34443,34444,41080,50002,55555]
portvar SHELLCODE_PORTS \!80
portvar ORACLE_PORTS 1024:
portvar SSH_PORTS 22
portvar FTP_PORTS [21,2100,3535]
portvar SIP_PORTS [5060,5061,5600]
portvar FILE_DATA_PORTS [\$HTTP_PORTS,110,143]
portvar GTP_PORTS [2123,2152,3386]
ipvar AIM_SERVERS [64.12.24.0/23,64.12.28.0/23,64.12.161.0/24,64.12.163.0/24,64.12.200.0/24,205.188.3.0/24,205.188.5.0/24,205.188.7.0/24,205.188.9.0/24,205.188.153.0/24,205.188.179.0/24,205.188.248.0/24]
var RULE_PATH /etc/snort/rules
var SO_RULE_PATH /etc/snort/so_rules
var PREPROC_RULE_PATH /etc/snort/preproc_rules
var WHITE_LIST_PATH ../rules
var BLACK_LIST_PATH ../rules
###################################################
# Step #2: Configure the decoder.  For more information, see README.decode
###################################################
config disable_decode_alerts
config disable_tcpopt_experimental_alerts
config disable_tcpopt_obsolete_alerts
config disable_tcpopt_ttcp_alerts
config disable_tcpopt_alerts
config disable_ipopt_alerts
config checksum_mode: all
###################################################
# Step #3: Configure the base detection engine.  For more information, see  README.decode
###################################################
config pcre_match_limit: 3500
config pcre_match_limit_recursion: 1500
config detection: search-method ac-split search-optimize max-pattern-len 20
config event_queue: max_queue 8 log 5 order_events content_length
config paf_max: 16000
###################################################
# Step #4: Configure dynamic loaded libraries.  
# For more information, see Snort Manual, Configuring Snort - Dynamic Modules
###################################################
dynamicpreprocessor directory /usr/local/lib/snort_dynamicpreprocessor/
dynamicengine /usr/local/lib/snort_dynamicengine/libsf_engine.so
dynamicdetection directory /usr/local/lib/snort_dynamicrules
###################################################
# Step #5: Configure preprocessors
# For more information, see the Snort Manual, Configuring Snort - Preprocessors
###################################################
preprocessor normalize_ip4
preprocessor normalize_tcp: ips ecn stream
preprocessor normalize_icmp4
preprocessor normalize_ip6
preprocessor normalize_icmp6
preprocessor frag3_global: max_frags 65536
preprocessor frag3_engine: policy windows detect_anomalies overlap_limit 10 min_fragment_length 100 timeout 180
preprocessor stream5_global: track_tcp yes, \\
   track_udp yes, \\
   track_icmp no, \\ 
   max_tcp 262144, \\
   max_udp 131072, \\
   max_active_responses 2, \\
   min_response_seconds 5
preprocessor stream5_tcp: log_asymmetric_traffic no, policy windows, \\
   detect_anomalies, require_3whs 180, \\
   overlap_limit 10, small_segments 3 bytes 150, timeout 180, \\
    ports client 21 22 23 25 42 53 79 109 110 111 113 119 135 136 137 139 143 \\
        161 445 513 514 587 593 691 1433 1521 1741 2100 3306 6070 6665 6666 6667 6668 6669 \\
        7000 8181 32770 32771 32772 32773 32774 32775 32776 32777 32778 32779, \\
    ports both 80 81 311 383 443 465 563 591 593 636 901 989 992 993 994 995 1220 1414 1830 2301 2381 2809 3037 3128 3702 4343 4848 5250 6988 7907 7000 7001 7144 7145 7510 7802 7777 7779 \\
        7801 7900 7901 7902 7903 7904 7905 7906 7908 7909 7910 7911 7912 7913 7914 7915 7916 \\
        7917 7918 7919 7920 8000 8008 8014 8028 8080 8085 8088 8090 8118 8123 8180 8243 8280 8300 8800 8888 8899 9000 9060 9080 9090 9091 9443 9999 11371 34443 34444 41080 50002 55555
preprocessor stream5_udp: timeout 180
preprocessor http_inspect: global iis_unicode_map unicode.map 1252 compress_depth 65535 decompress_depth 65535
preprocessor http_inspect_server: server default \\
    http_methods { GET POST PUT SEARCH MKCOL COPY MOVE LOCK UNLOCK NOTIFY POLL BCOPY BDELETE BMOVE LINK UNLINK OPTIONS HEAD DELETE TRACE TRACK CONNECT SOURCE SUBSCRIBE UNSUBSCRIBE PROPFIND PROPPATCH BPROPFIND BPROPPATCH RPC_CONNECT PROXY_SUCCESS BITS_POST CCM_POST SMS_POST RPC_IN_DATA RPC_OUT_DATA RPC_ECHO_DATA } \\
    chunk_length 500000 \\
    server_flow_depth 0 \\
    client_flow_depth 0 \\
    post_depth 65495 \\
    oversize_dir_length 500 \\
    max_header_length 750 \\
    max_headers 100 \\
    max_spaces 200 \\
    small_chunk_length { 10 5 } \\
    ports { 80 81 311 383 591 593 901 1220 1414 1741 1830 2301 2381 2809 3037 3128 3702 4343 4848 5250 6988 7000 7001 7144 7145 7510 7777 7779 8000 8008 8014 8028 8080 8085 8088 8090 8118 8123 8180 8181 8243 8280 8300 8800 8888 8899 9000 9060 9080 9090 9091 9443 9999 11371 34443 34444 41080 50002 55555 } \\
    non_rfc_char { 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 } \\
    enable_cookie \\
    extended_response_inspection \\
    inspect_gzip \\
    normalize_utf \\
    unlimited_decompress \\
    normalize_javascript \\
    apache_whitespace no \\
    ascii no \\
    bare_byte no \\
    directory no \\
    double_decode no \\
    iis_backslash no \\
    iis_delimiter no \\
    iis_unicode no \\
    multi_slash no \\
    utf_8 no \\
    u_encode yes \\
    webroot no
preprocessor rpc_decode: 111 32770 32771 32772 32773 32774 32775 32776 32777 32778 32779 no_alert_multiple_requests no_alert_large_fragments no_alert_incomplete
preprocessor bo
preprocessor ftp_telnet: global inspection_type stateful encrypted_traffic no check_encrypted
preprocessor ftp_telnet_protocol: telnet \\
    ayt_attack_thresh 20 \\
    normalize ports { 23 } \\
    detect_anomalies
preprocessor ftp_telnet_protocol: ftp server default \\
    def_max_param_len 100 \\
    ports { 21 2100 3535 } \\
    telnet_cmds yes \\
    ignore_telnet_erase_cmds yes \\
    ftp_cmds { ABOR ACCT ADAT ALLO APPE AUTH CCC CDUP } \\
    ftp_cmds { CEL CLNT CMD CONF CWD DELE ENC EPRT } \\
    ftp_cmds { EPSV ESTA ESTP FEAT HELP LANG LIST LPRT } \\
    ftp_cmds { LPSV MACB MAIL MDTM MIC MKD MLSD MLST } \\
    ftp_cmds { MODE NLST NOOP OPTS PASS PASV PBSZ PORT } \\
    ftp_cmds { PROT PWD QUIT REIN REST RETR RMD RNFR } \\
    ftp_cmds { RNTO SDUP SITE SIZE SMNT STAT STOR STOU } \\
    ftp_cmds { STRU SYST TEST TYPE USER XCUP XCRC XCWD } \\
    ftp_cmds { XMAS XMD5 XMKD XPWD XRCP XRMD XRSQ XSEM } \\
    ftp_cmds { XSEN XSHA1 XSHA256 } \\
    alt_max_param_len 0 { ABOR CCC CDUP ESTA FEAT LPSV NOOP PASV PWD QUIT REIN STOU SYST XCUP XPWD } \\
    alt_max_param_len 200 { ALLO APPE CMD HELP NLST RETR RNFR STOR STOU XMKD } \\
    alt_max_param_len 256 { CWD RNTO } \\
    alt_max_param_len 400 { PORT } \\
    alt_max_param_len 512 { SIZE } \\
    chk_str_fmt { ACCT ADAT ALLO APPE AUTH CEL CLNT CMD } \\
    chk_str_fmt { CONF CWD DELE ENC EPRT EPSV ESTP HELP } \\
    chk_str_fmt { LANG LIST LPRT MACB MAIL MDTM MIC MKD } \\
    chk_str_fmt { MLSD MLST MODE NLST OPTS PASS PBSZ PORT } \\
    chk_str_fmt { PROT REST RETR RMD RNFR RNTO SDUP SITE } \\
    chk_str_fmt { SIZE SMNT STAT STOR STRU TEST TYPE USER } \\
    chk_str_fmt { XCRC XCWD XMAS XMD5 XMKD XRCP XRMD XRSQ } \\ 
    chk_str_fmt { XSEM XSEN XSHA1 XSHA256 } \\
    cmd_validity ALLO < int [ char R int ] > \\    
    cmd_validity EPSV < [ { char 12 | char A char L char L } ] > \\
    cmd_validity MACB < string > \\
    cmd_validity MDTM < [ date nnnnnnnnnnnnnn[.n[n[n]]] ] string > \\
    cmd_validity MODE < char ASBCZ > \\
    cmd_validity PORT < host_port > \\
    cmd_validity PROT < char CSEP > \\
    cmd_validity STRU < char FRPO [ string ] > \\    
    cmd_validity TYPE < { char AE [ char NTC ] | char I | char L [ number ] } >
preprocessor ftp_telnet_protocol: ftp client default \\
    max_resp_len 256 \\
    bounce yes \\
    ignore_telnet_erase_cmds yes \\
    telnet_cmds yes
preprocessor smtp: ports { 25 465 587 691 } \\
    inspection_type stateful \\
    b64_decode_depth 0 \\
    qp_decode_depth 0 \\
    bitenc_decode_depth 0 \\
    uu_decode_depth 0 \\
    log_mailfrom \\
    log_rcptto \\
    log_filename \\
    log_email_hdrs \\
    normalize cmds \\
    normalize_cmds { ATRN AUTH BDAT CHUNKING DATA DEBUG EHLO EMAL ESAM ESND ESOM ETRN EVFY } \\
    normalize_cmds { EXPN HELO HELP IDENT MAIL NOOP ONEX QUEU QUIT RCPT RSET SAML SEND SOML } \\
    normalize_cmds { STARTTLS TICK TIME TURN TURNME VERB VRFY X-ADAT X-DRCP X-ERCP X-EXCH50 } \\
    normalize_cmds { X-EXPS X-LINK2STATE XADR XAUTH XCIR XEXCH50 XGEN XLICENSE XQUE XSTA XTRN XUSR } \\
    max_command_line_len 512 \\
    max_header_line_len 1000 \\
    max_response_line_len 512 \\
    alt_max_command_line_len 260 { MAIL } \\
    alt_max_command_line_len 300 { RCPT } \\
    alt_max_command_line_len 500 { HELP HELO ETRN EHLO } \\
    alt_max_command_line_len 255 { EXPN VRFY ATRN SIZE BDAT DEBUG EMAL ESAM ESND ESOM EVFY IDENT NOOP RSET } \\
    alt_max_command_line_len 246 { SEND SAML SOML AUTH TURN ETRN DATA RSET QUIT ONEX QUEU STARTTLS TICK TIME TURNME VERB X-EXPS X-LINK2STATE XADR XAUTH XCIR XEXCH50 XGEN XLICENSE XQUE XSTA XTRN XUSR } \\
    valid_cmds { ATRN AUTH BDAT CHUNKING DATA DEBUG EHLO EMAL ESAM ESND ESOM ETRN EVFY } \\ 
    valid_cmds { EXPN HELO HELP IDENT MAIL NOOP ONEX QUEU QUIT RCPT RSET SAML SEND SOML } \\
    valid_cmds { STARTTLS TICK TIME TURN TURNME VERB VRFY X-ADAT X-DRCP X-ERCP X-EXCH50 } \\
    valid_cmds { X-EXPS X-LINK2STATE XADR XAUTH XCIR XEXCH50 XGEN XLICENSE XQUE XSTA XTRN XUSR } \\
    xlink2state { enabled }
preprocessor ssh: server_ports { 22 } \\
                  autodetect \\
                  max_client_bytes 19600 \\
                  max_encrypted_packets 20 \\
                  max_server_version_len 100 \\
                  enable_respoverflow enable_ssh1crc32 \\
                  enable_srvoverflow enable_protomismatch
preprocessor dcerpc2: memcap 102400, events [co ]
preprocessor dcerpc2_server: default, policy WinXP, \\
    detect [smb [139,445], tcp 135, udp 135, rpc-over-http-server 593], \\
    autodetect [tcp 1025:, udp 1025:, rpc-over-http-server 1025:], \\
    smb_max_chain 3, smb_invalid_shares [\"C\$\", \"D\$\", \"ADMIN\$\"]
preprocessor dns: ports { 53 } enable_rdata_overflow
preprocessor ssl: ports { 443 465 563 636 989 992 993 994 995 7801 7802 7900 7901 7902 7903 7904 7905 7906 7907 7908 7909 7910 7911 7912 7913 7914 7915 7916 7917 7918 7919 7920 }, trustservers, noinspect_encrypted
preprocessor sensitive_data: alert_threshold 25
preprocessor sip: max_sessions 40000, \\
   ports { 5060 5061 5600 }, \\
   methods { invite \\
             cancel \\
             ack \\
             bye \\
             register \\
             options \\
             refer \\
             subscribe \\
             update \\
             join \\
             info \\
             message \\
             notify \\
             benotify \\
             do \\
             qauth \\
             sprack \\
             publish \\
             service \\
             unsubscribe \\
             prack }, \\
   max_uri_len 512, \\
   max_call_id_len 80, \\
   max_requestName_len 20, \\
   max_from_len 256, \\
   max_to_len 256, \\
   max_via_len 1024, \\
   max_contact_len 512, \\
   max_content_len 2048 
preprocessor imap: \\
   ports { 143 } \\
   b64_decode_depth 0 \\
   qp_decode_depth 0 \\
   bitenc_decode_depth 0 \\
   uu_decode_depth 0
preprocessor pop: \\
   ports { 110 } \\
   b64_decode_depth 0 \\
   qp_decode_depth 0 \\
   bitenc_decode_depth 0 \\
   uu_decode_depth 0
preprocessor modbus: ports { 502 }
preprocessor dnp3: ports { 20000 } \\
   memcap 262144 \\
   check_crc
preprocessor reputation: \\
   memcap 500, \\
   priority whitelist, \\
   nested_ip inner, \\
   whitelist \$WHITE_LIST_PATH/white_list.rules, \\
   blacklist \$BLACK_LIST_PATH/black_list.rules 
###################################################
# Step #6: Configure output plugins
# For more information, see Snort Manual, Configuring Snort - Output Modules
###################################################
include classification.config
include reference.config
###################################################
# Step #7: Customize your rule set
# For more information, see Snort Manual, Writing Snort Rules
#
# NOTE: All categories are enabled in this conf file
###################################################
include \$RULE_PATH/local.rules
###################################################
# Step #8: Customize your preprocessor and decoder alerts
# For more information, see README.decoder_preproc_rules
###################################################
###################################################
# Step #9: Customize your Shared Object Snort Rules
# For more information, see http://vrt-blog.snort.org/2009/01/using-vrt-certified-shared-object-rules.html
###################################################
include threshold.conf
config policy_mode: inline
config daq: nfq
config daq_dir: /usr/local/lib/daq
config daq_mode: inline
config daq_var: queue=0
""" > /etc/snort/snort.conf
```

Verify instalation
```bash
sudo snort -v
```


Project
```bash

# Configure rules file 
echo """
ipvar VAR [10.10.10.0/24,10.10.20.0/24]

#[action] [protocol] [sourceIP] [sourceport] -> [destIP] [destport] ( [Rule options] )

#SQL
drop tcp any any -> \$VAR any (msg:\" SQL Injection Based on or TRUE \"; sid:1000000; rev:1; content:\"or \"; nocase;flow:to_server,established;)
drop tcp any any -> \$VAR any (msg:\" SQL Injection Based on DROP \"; sid:1000001; rev:1; content\"dr\"; nocase;flow:to_server,established;)

#XSS
drop tcp any any -> \$VAR any (msg:\" XSS Attack <script> \"; sid:1000002; rev:1; conten\"<script> \"; nocase;flow:to_server,established;)
drop tcp any any -> \$VAR any (msg:\" XSS Attack <img ...> \"; sid:1000003; rev:1; conten\"<img \"; nocase; flow:to_server,established;)
""" > /etc/snort/rules/local.rules


# Configure conf file 
echo """
include rules/local.rules
config policy_mode: inline
config daq:nfq
config daq_dir: /usr/local/lib/daq
config daq_mode: inline
config daq_var: queue=0
""" > /etc/snort/conf.conf

mkdir /var/log/snort

snort -Q --daq nfq --daq-var queue=0 -c /etc/snort/conf.conf -A console -dev
#snort -Q --daq nfq --daq-var queue=0 -c /etc/snort/conf.conf -vd -K ascii -l logs

```
