#!/usr/bin/env python3

import sys
import argparse
from os import listdir
from os.path import isfile, join

VERSION = "0.0.1"

entries = []


def get_entries(readdir):
    global entries
    only_files = [f for f in listdir(readdir) if isfile(join(readdir, f))]
    all_entries = list(map(lambda x: tuple(x.split('.', 1)[0].split('~')), only_files))
    entries = sorted(list(set(all_entries)))


def get_entry_and_write(filename, f):
    with open(filename, 'r', encoding='utf-8') as file:
        for line in file:
            if line.strip():
                line = line.rstrip()
                f.write(f'{line}\n')


def write_groups(readdir, writedir):
    global entries
    nof_entries = len(entries)
    print(f'NofEntries = {nof_entries}')
    allentries = []
    group = {}
    last_first_letter = ''
    last_first_hanzi = ''
    for entry in entries:
        print(f'Processing entry {entry}')
        filename = '~'.join(entry) + '.tex'
        allentries.append(filename)
        first_letter = entry[0].upper()[0]
        if last_first_letter != first_letter:
            last_first_letter = first_letter
            print(f'Genenerating Group {first_letter}')
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
            file.write(f'\\section*{{{c}}}')
            file.write(f'\\addcontentsline{{toc}}{{section}}{{{c}}}\n\n')
            for e in group[c]:
                first_hanzi = e.split('.', 1)[0].split('~')[2]
                if last_first_hanzi != first_hanzi:
                    last_first_hanzi = first_hanzi
                    if not ('a' <= last_first_hanzi <= 'z'):
                        file.write(f'%%%%%%%%%% {first_hanzi} %%%%%%%%%%\n')
                        file.write(f'\\subsection*{{{first_hanzi}}}\n\n')
                get_entry_and_write(readdir + '/' + e, file)
                file.write('\n')
            file.write('%%%%% EOF %%%%%\n\n')


def main():
    parser = argparse.ArgumentParser(description='''
        Processa arquivos verbete e
        separa cada verbete em arquivo próprio''')
    parser.add_argument('--version', '-V', action='version', version=f'%(prog)s v{VERSION}')
    parser.add_argument('--read', '--readdir', '-r', dest='read_dir', action='store')
    parser.add_argument('--write', '--writedir', '-w', dest='write_dir', action='store')
    args = parser.parse_args()
    get_entries(args.read_dir)
    write_groups(args.read_dir, args.write_dir)
    return 0


if __name__ == "__main__":
    errno = main()
    sys.exit(errno)
