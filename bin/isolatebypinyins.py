#!/usr/bin/env python3

import sys
import argparse
import re

VERSION = "0.1.0"

entries = {}

#: Character code ranges for pertinent CJK ideograph Unicode blocks.
characters = (
    "\u3007"  # Ideographic number zero, see issue #17
    "\u4E00-\u9FFF"  # CJK Unified Ideographs
    "\u3400-\u4DBF"  # CJK Unified Ideographs Extension A
    "\uF900-\uFAFF"  # CJK Compatibility Ideographs
)
if sys.maxunicode > 0xFFFF:
    characters += (
        "\U00020000-\U0002A6DF"  # CJK Unified Ideographs Extension B
        "\U0002A700-\U0002B73F"  # CJK Unified Ideographs Extension C
        "\U0002B740-\U0002B81F"  # CJK Unified Ideographs Extension D
        "\U0002F800-\U0002FA1F"  # CJK Compatibility Ideographs Supplement
    )


def extract_chinese_chars(hanzi):
    # Regex pattern for Chinese characters (CJK Unified Ideographs)
    chinese_pattern = re.compile(rf"[{characters}]")
    return chinese_pattern.findall(hanzi)


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

            if '\\begin' in line and 'Entry' in line:
                begin_entry_found = True

                substrings = extract_strings_between_delimiters('{', '}', line)
                #hanzis = extract_chinese_chars(substrings[1])
                hanzis = substrings[1]
                h_chars_to_remove = ["-", "…", "（", "）", "，"]
                hanzis = "".join([c for c in substrings[1].lower() if c not in h_chars_to_remove])
                print(hanzis)
                p_chars_to_remove = [" ", "·", "'", "-", "(", ")"]
                pinyin_str = "".join([c for c in substrings[2].lower() if c not in p_chars_to_remove])
                print(pinyin_str)
                pinyin_strs = re.split(r'(?:\[(.*)\]|([a-zA-Z]+[1-5]))', pinyin_str)
                print(pinyin_strs)
                pinyins = [x for x in pinyin_strs if x != '' and x is not None]
                print(pinyins)
                strokes = substrings[3].split(',')
                print(strokes)

                if len(hanzis) != len(strokes):
                    print(f'***** ERROR: in {hanzis}: number of hanzis and strokes are different: {len(hanzis)} != {len(strokes)}')
                    sys.exit(1)

                if len(hanzis) != len(pinyins):
                    print(f'***** ERROR: in {filename}: number of hanzis and pinyins are different: {len(hanzis)} != {len(pinyins)}')
                    sys.exit(1)

                fn = ''
                for i in range(len(hanzis)):
                    if strokes[i] == '∅':
                        fn += '{0}~∅~{1}~'.format(pinyins[i], hanzis[i])
                    else:
                        fn += '{0}~{1:03d}~{2}~'.format(pinyins[i], int(strokes[i]), hanzis[i])
                entry_filename = fn.rstrip('~') + '.tex'

                if entry_filename in entries and not substrings[1].isalpha():
                    print(f'***** ERROR: entry {entry_filename} exists')
                    sys.exit(1)
                else:
                    entries[entry_filename] = [line]

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
    parser.add_argument('--version', '-V', action='version', version=f'%(prog)s v{VERSION}')
    parser.add_argument('--write-dir', '-w', dest='write_dir', action='store')
    parser.add_argument('filename')
    args = parser.parse_args()

    read_entries(args.filename)
    write_entry_to_a_separate_file(args.write_dir)

    return 0


if __name__ == "__main__":
    errno = main()
    sys.exit(errno)
