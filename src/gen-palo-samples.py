#!/usr/bin/env python3 
"""
 USAGE:
   - generates "live" logs based on the palo alot log samples
   - there are 3 dates therein we need to simulate
   - <14>Feb  22 21:32:20 pa-fw-2 1,2012/04/08 01:24:58,001606001116,THREAT,url,1,2012/04/08 01:24:56,192.168.0.2,74.125.224.220,0.0.0.0,0.0.0.0,rule1,crusher,,flash,vsys1,trust,untrust,ethernet1/2,ethernet1/1,forwardAll,2012/04/08 01:24:57,45553,1,51397,80,0,0,0x208000,tcp,alert,"s0.2mdn.net/instream/ads_sdk_config.xml",(9999),block-list,informational,client-to-server,0,0x0,192.168.0.0-192.168.255.255,United States,0,text/xml
       - "Feb 22 21:32:20"
            - TIME_ONE
            - 0
       - "2012/04/08 01:24:58
            - TIME_BIG
            - 1
            
       - "2012/04/08 01:24:56
            - TIME_SMALL
            - 6
       - "2012/04/08 01:24:57"
            - TIME_MED
            - 21

    - after split [
        '<14>Feb  22 21:32:20 pa-fw-2 1', 
        '2012/04/08 01:24:58', '001606001116', 'THREAT', 'url', '1', 
        '2012/04/08 01:24:56', '192.168.0.2', '74.125.224.220', '0.0.0.0', '0.0.0.0', 'rule1', 'crusher', '', 'flash', 'vsys1', 'trust', 'untrust', 'ethernet1/2', 'ethernet1/1', 'forwardAll', '2012/04/08 01:24:57', '45553', '1', '51397', '80', '0', '0', '0x208000', 'tcp', 'alert', '"s0.2mdn.net/instream/ads_sdk_config.xml"', '(9999)', 'block-list', 'informational', 'client-to-server', '0', '0x0', '192.168.0.0-192.168.255.255', 'United States', '0', 'text/xml\n']
NOW_DATE
"""
import argparse
from datetime import datetime,timedelta
import re
import sys
import socket

def get_log_lines(file):
    with open(file,'r+') as f:
        log_lines = f.readlines()
        ### only grab the syslog ones
        return [i for i in log_lines if i[0] == '<']

def update_time(line):
    """
    - tries to replace the time in the lines; deduces what's where based on split 
>>> re.sub("(?i)[a-z]+\s+[0-9]+\s+[0-9]+:[0-9]+:[0-9]+","HELLOWORLD",dudestring)
>>> nowdude.strftime("%b %d %H:%M:%S")
    """
    split_line = line.split(',')
    split_size = len(split_line)
    header = split_line[0]
    now_time = datetime.now()
    now_minus_onesec = now_time - timedelta(seconds=1)
    now_minus_twosec = now_time - timedelta(seconds=2)
    now_minus_threesec = now_time - timedelta(seconds=3)

    now_format_header = now_time.strftime("%b %d %H:%M:%S")
    now_minus_onesec_format = now_minus_onesec.strftime("%Y/%m/%d %H:%M:%S")
    now_minus_twosec_format = now_minus_twosec.strftime("%Y/%m/%d %H:%M:%S")
    now_minus_threesec_format = now_minus_threesec.strftime("%Y/%m/%d %H:%M:%S")


    ### now the times differ based on position, simulate this 
    # index_1 > index_21 > index_6 split ; split < 22 does not have index 21
    #   - these times are well formatted, no additional need to gsub
    split_line[1] = now_minus_onesec_format
    split_line[6] = now_minus_threesec_format
    good_header = re.sub("(?i)[a-z]+\s+[0-9]+\s+[0-9]+:[0-9]+:[0-9]+",now_format_header,header)
    split_line[0] = good_header
    if split_size < 22:
        return ','.join(split_line)
    else:
        if split_line[21] == '0':
            ### return/ignore
            return ','.join(split_line)
        else:
            split_line[21] = now_minus_twosec_format
            return ','.join(split_line)
        

def main():
    parser = argparse.ArgumentParser(
        prog = 'gen-palo-samples.py',
        description = 'a helper script to generate palo logs with current dates to stdout or to a syslog target')
    parser.add_argument('-s', '--syslog', action=argparse.BooleanOptionalAction,help='bool for syslog mode')
    parser.add_argument('-i', '--ip',help="target ip")
    parser.add_argument('-t', '--tcp',action=argparse.BooleanOptionalAction,help="tcp enabled; if not ships to udp target")
    parser.add_argument('-p', '--port',type=int,help='target port')
    parser.add_argument('-f', '--file',help='the source file to read sample logs from',required=True)
    args = parser.parse_args()
    if len(sys.argv) == 1:
        parser.print_help()
    if args.file:
        if args.syslog:
            if args.tcp:
                if args.port and args.ip:
                    try:
                        sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
                        sock.connect((args.ip,args.port))
                        lines = get_log_lines(args.file)
                        #### build the connection and then send  the modified line
                        for i in lines:
                            updated_line = update_time(i)
                            sock.sendall(updated_line.encode('utf-8'))
                        sock.close()
                    except Exception as e:
                        print(e)
                else:
                   parser.print_help()
            else:
                if args.port and args.ip:
                    try:
                        sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
                        lines = get_log_lines(args.file)
                        for i in lines:
                            updated_line = update_time(i)
                            sock.sendto(updated_line.encode('utf-8'), (args.ip, args.port))
                    except Exception as e:
                        print(e)
                else:
                   parser.print_help()
    else:
        parser.print_help()
if __name__ == '__main__':
    main()
