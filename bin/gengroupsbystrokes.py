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


def write_strokes(readdir, writedir):
    global entries
    nof_entries = len(entries)
    print(f'NofEntries = {nof_entries}')
    allentries = []
    strokes = {}
    last_strokes = ''
    last_first_hanzi = ''
    for entry in entries:
        print(f'Processing entry {entry[0]}')
        filename = '~'.join(list(entry)) + '.tex'
        allentries.append(filename)
        first_strokes = entry[0]
        if last_strokes != first_strokes:
            last_strokes = first_strokes
            print(f'Genenerating Strokes {first_strokes}')
        if first_strokes not in strokes:
            strokes[first_strokes] = list()
        strokes[first_strokes].append(filename)
    for s in strokes.keys():
        filename = writedir + '/' + s + '.tex'
        print(f'Writting Strokes {filename}')
        with open(filename, 'w', encoding='utf-8') as file:
            if s != '∅':
                s_as_int = int(s)
            file.write('%%%\n')
            if s != '∅':
                 file.write(f'%%% {s_as_int:d}画\n')
            else:
                 file.write('%%% ∅画\n')
            file.write('%%%\n')
            if s != '∅':
                file.write(f'\\section*{{{s_as_int:d}画}}')
                file.write(f'\\addcontentsline{{toc}}{{section}}{{{s_as_int:d}画}}\n\n')
            else:
                file.write(f'\\section*{{∅画}}')
                file.write(f'\\addcontentsline{{toc}}{{section}}{{∅画}}\n\n')

            for e in strokes[s]:
                first_hanzi = e.split('.', 1)[0].split('~')[1]
                if last_first_hanzi != first_hanzi:
                    last_first_hanzi = first_hanzi
                    file.write(f'%%%%%%%%%% {first_hanzi} %%%%%%%%%%\n')
                    file.write(f'\\subsection*{{{first_hanzi.upper()}}}\n\n')
                get_entry_and_write(readdir + '/' + e, file)
                file.write('\n')
            file.write('%%%%% EOF %%%%%\n\n')


def main():
    parser = argparse.ArgumentParser(description='''
        Processa arquivos verbete e
        separa cada verbete em arquivo próprio,
        pelo número de traços''')
    parser.add_argument('--version', '-V', action='version', version=f'%(prog)s v{VERSION}')
    parser.add_argument('--read', '--readdir', '-r', dest='read_dir', action='store')
    parser.add_argument('--write', '--writedir', '-w', dest='write_dir', action='store')
    args = parser.parse_args()
    get_entries(args.read_dir)
    write_strokes(args.read_dir, args.write_dir)
    return 0


if __name__ == "__main__":
    errno = main()
    sys.exit(errno)
