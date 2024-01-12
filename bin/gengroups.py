#!/usr/bin/env /usr/local/bin/python3.9

import sys
import argparse
from os import listdir
from os.path import isfile, join

VERSION = "0.0.1"

entries = []

def get_entries_from(readdir):
    global entries
    only_files = [ f for f in listdir(readdir) if isfile(join(readdir, f))]
    all_entries = list(map(lambda x: tuple(x.split('.', 1)[0].split('-')), only_files))
    entries = sorted(list(set(all_entries)))
           
def write_groups(readdir, writedir):
    global entries
    
    nof_entries = len(entries)
    print(f'NofEntries = {nof_entries}')
    
    group = {}
    last_first_letter = ''
    
    for entry in entries:
        first_letter = entry[0].upper()[0]
        if last_first_letter != first_letter:
            last_first_letter = first_letter
            print(f'Genenerating Group {first_letter}')
        filename = '-'.join(list(entry)) + '.tex'
        if first_letter not in group:
            group[first_letter] = list()

        group[first_letter].append(filename)
            
    for c in group.keys():
        filename = writedir + '/' + c + '.tex'
        print(f'Writting Group {filename}')
        
        with open(filename, 'w', encoding='utf-8') as file:
            file.write('%%%\n')
            file.write(f'%%% {c}\n')
            file.write('%%%\n')
            file.write(f'\\section*{{{c}}}\n')
            file.write(f'\\addcontentsline{{toc}}{{section}}{{{c}}}\n\n')
                                                              
            for e in group[c]:
                f = readdir + '/' + e
                file.write(f'\\input{{{f}}}\n')
                                                              
            file.write('\n%%%%% EOF %%%%%\n')

def main():
    parser = argparse.ArgumentParser(description='''
        Processa arquivos verbete e                                                
        separa cada verbete em arquivo próprio''')
    parser.add_argument('--version', '-V', action='version', 
        version=f'%(prog)s v{VERSION}')
    parser.add_argument('--read', '--readdir', '-r', dest='read_dir', action='store')
    parser.add_argument('--write', '--writedir', '-w', dest='write_dir', action='store')

    args = parser.parse_args()
    
    get_entries_from(args.read_dir)
    write_groups(args.read_dir, args.write_dir)

    return 0;
    
if __name__ == "__main__":
    errno = main()
    sys.exit(errno)
