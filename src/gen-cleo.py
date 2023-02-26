#!/usr/bin/env python3
import sys
from datetime import datetime, timedelta
"""
USAGE:
    - read a cleo xml file and update the timestamps to output simulate current
    - YYYY/mm/dd H:M:S
"""
now = datetime.now()
def main():
    if len(sys.argv) == 3:
        source = open(sys.argv[1], 'r').read()
        source = str(source)
        for i in range(1,13):
            now_delta = now - timedelta(seconds=i)
            now_delta_str = now_delta.strftime("%Y/%m/%d %H:%M:%S")
            print(f'DELTA STR: {now_delta_str}')
            if i > 9:
                change_str=f'CHANGEME_0{i}'
                source = source.replace(change_str, now_delta_str)
            else:
                change_str=f'CHANGEME_00{i}'
                source = source.replace(change_str, now_delta_str)
        with open(sys.argv[2], 'w+') as f:
            f.write(source)
    else:
        print(f'{sys.argv[0]}: want <source_file> and <target_path>')
        sys.exit()
if __name__ == '__main__':
    main()
