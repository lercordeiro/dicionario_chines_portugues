#!/usr/bin/env python3

import sys
import argparse
import re

VERSION = "0.1.0"

entries = {}

def extract_strings_between_delimiters(bd, ed, istr):
    substrings = []
    in_brackets = False
    current_substring = ''
    
    for c in istr:
        if c == bd:
            in_brackets = True
        elif c == ed and in_brackets:
            substrings.append(current_substring)
            current_substring = ''
            in_brackets = False
        elif in_brackets:
            current_substring += c
    
    if current_substring:
        substrings.append(current_substring)
        
    return substrings
    
    
def read_entries(filename):
    global entries
    begin_entry_found = False
    entry_filename = ''

    with open(filename, 'r', encoding='utf-8') as file:
        for line in file:
            line = line.rstrip()
            
            if '\\begin' in line and 'entry' in line:
                begin_entry_found = True

                substrings = extract_strings_between_delimiters('{', '}', line)
                s = substrings[1]
                s = s.replace("\ ", "")
                s = s.replace("-", "")
                s = s.replace("…", "")
                s = s.replace("\u2026", "")
                s = s.replace("（", "")
                s = s.replace("）","")
                s = s.replace("/〇","")
                hanzis = list(s)
                print(hanzis)
                s = substrings[2].lower()
                s = s.replace(" ","")
                s = s.replace("·","")
                s = s.replace("'","")
                s = s.replace("-","")
                s = s.replace("(", "")
                s = s.replace(")","")
                pinyin_str = s
                print(pinyin_str)
                pinyin_strs = re.split(r'(?:\[(.*)\]|([a-zA-Z]+[1-5]))', pinyin_str)
                print(pinyin_strs)
                pinyins = [x for x in pinyin_strs if x != '' and x != None ]
                print(pinyins)
                strokes = substrings[3].split(',')
                print(strokes)
                
                if len(hanzis) != len(strokes):
                    print(f'***** ERROR: in {hanzis}: number of hanzis and strokes are different: {len(hanzis)} != {len(strokes)}')
                    sys.exit(1)
                    
                if len(hanzis) != len(pinyins):
                    print(f'***** ERROR: in {filename}: number of hanzis and pinyins are different: {len(hanzis)} != {len(pinyins)}')
                    sys.exit(1)
                    
                filename = ''
                for i in range(len(hanzis)):
                    filename += '{0}~{1:03d}~{2}~'.format(pinyins[i], int(strokes[i]), hanzis[i])
                entry_filename = filename.rstrip('~') + '.tex'
                
                if entry_filename in entries:
                    print(f'***** ERROR: entry {entry_filename} exists')
                    sys.exit(1)
                else:
                    entries[entry_filename] = [ line ]
                
            elif '\\end' in line and 'entry' in line:
                begin_entry_found = False
                entries[entry_filename].append(line)

            elif begin_entry_found:
                entries[entry_filename].append(line)
                
            else:
                continue
        
        file.close()
        
        
def write_entry_to_a_separate_file(write_dir):
    global entries
    
    nof_entries = len(entries)
    print(f'NofEntries = {nof_entries}')
    
    print(f'WriteDir = {write_dir}')
    
    for entry in entries:
        print(f'Entry = {entry}')
        entry_text = entries[entry]
        with open(write_dir + '/' + entry, 'w', encoding='utf-8') as file:
            for line in entry_text:
                file.write(line + '\n')

def main():
    parser = argparse.ArgumentParser(description='''
        Processa arquivos verbete e                                                
        separa cada verbete em arquivo próprio''')
    parser.add_argument('--version', '-V', action='version', 
        version=f'%(prog)s v{VERSION}')
    parser.add_argument('--write-dir', '-w', dest='write_dir',     
        action='store')
    parser.add_argument('filename')
    args = parser.parse_args()
    
    read_entries(args.filename)
    write_entry_to_a_separate_file(args.write_dir)
    
    return 0;
    
if __name__ == "__main__":
    errno = main()
    sys.exit(errno)
