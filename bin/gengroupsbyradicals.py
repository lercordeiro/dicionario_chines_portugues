#!/usr/bin/env python3

import sys
import argparse
from os import listdir
from os.path import isfile, join

VERSION = "0.0.1"

entries = []

kangxi = {
    '∅': {'number': 0, 'meaning': 'não existe'},

    '⼀': {'number': 1, 'meaning': 'um'},
    '⼁': {'number': 2, 'meaning': 'linha'},
    '⼂': {'number': 3, 'meaning': 'ponto, indica um fim', 'variants': '乀,乁'},
    '⼃': {'number': 4, 'meaning': 'cortar, dobrar'},
    '⼄': {'number': 5, 'meaning': 'segundo, anzol', 'variants': '乚、乛、⺄'},
    '⼅': {'number': 6, 'meaning': 'gancho'},
    '⼆': {'number': 7, 'meaning': 'dois'},
    '⼇': {'number': 8, 'meaning': 'tampa'},
    '⼈': {'number': 9, 'meaning': 'pessoa', 'variants': '亻、𠆢'},

    '⼉': {'number': 10, 'meaning': 'pernas'},
    '⼊': {'number': 11, 'meaning': 'entrar, juntar-se'},
    '⼋': {'number': 12, 'meaning': 'oito', 'variants': '丷'},
    '⼌': {'number': 13, 'meaning': 'largo, exterior'},
    '⼍': {'number': 14, 'meaning': 'capa de pano'},
    '⼎': {'number': 15, 'meaning': 'gelo'},
    '⼏': {'number': 16, 'meaning': 'mesa pequena'},
    '⼐': {'number': 17, 'meaning': 'receptáculo, caixa aberta'},
    '⼑': {'number': 18, 'meaning': 'faca', 'variants': '刂、⺈'},
    '⼒': {'number': 19, 'meaning': 'poder, força'},

    '⼓': {'number': 20, 'meaning': 'invólucro'},
    '⼔': {'number': 21, 'meaning': 'colher'},
    '⼕': {'number': 22, 'meaning': 'caixa'},
    '⼖': {'number': 23, 'meaning': 'compartimento oculto'},
    '⼗': {'number': 24, 'meaning': 'dez, completo, perfeito'},
    '⼘': {'number': 25, 'meaning': 'advinhação, divinação'},
    '⼙': {'number': 26, 'meaning': 'foca', 'variants': '㔾'},
    '⼚': {'number': 27, 'meaning': 'penhasco, precipício'},
    '⼛': {'number': 28, 'meaning': 'privado'},
    '⼜': {'number': 29, 'meaning': 'mão direita, e, novamente'},

    '⼝': {'number': 30, 'meaning': 'boca'},
    '⼞': {'number': 31, 'meaning': 'compartimento, recinto'},
    '⼟': {'number': 32, 'meaning': 'terra'},
    '⼠': {'number': 33, 'meaning': 'acadêmico, bacharel'},
    '⼡': {'number': 34, 'meaning': 'ir'},
    '⼢': {'number': 35, 'meaning': 'ir devagar'},
    '⼣': {'number': 36, 'meaning': 'tarde, pôr do sol'},
    '⼤': {'number': 37, 'meaning': 'grande, muito'},
    '⼥': {'number': 38, 'meaning': 'mulher, fêmea'},
    '⼦': {'number': 39, 'meaning': 'criança, semente'},

    '⼧': {'number': 40, 'meaning': 'teto, telhado'},
    '⼨': {'number': 41, 'meaning': 'polegar, polegada'},
    '⼩': {'number': 42, 'meaning': 'pequeno, insignificante', 'variants': '⺌、⺍'},
    '⼪': {'number': 43, 'meaning': 'manco, coxo', 'variants': '尣'},
    '⼫': {'number': 44, 'meaning': 'cadáver'},
    '⼬': {'number': 45, 'meaning': 'brotar, germinar'},
    '⼭': {'number': 46, 'meaning': 'montanha'},
    '⼮': {'number': 47, 'meaning': 'rio', 'variants': '川'},
    '⼯': {'number': 48, 'meaning': 'trabalho'},
    '⼰': {'number': 49, 'meaning': 'próprio, a si mesmo', 'variants': '⺒'},

    '⼱': {'number': 50, 'meaning': 'turbante, cachecol'},
    '⼲': {'number': 51, 'meaning': 'oposto, seco'},
    '⼳': {'number': 52, 'meaning': 'baixo, minúsculo', 'variants': '么'},
    '⼴': {'number': 53, 'meaning': 'casa em um penhasco'},
    '⼵': {'number': 54, 'meaning': 'passada longa'},
    '⼶': {'number': 55, 'meaning': 'duas mãos, vinte, arco'},
    '⼷': {'number': 56, 'meaning': 'tiro, flecha'},
    '⼸': {'number': 57, 'meaning': 'arco'},
    '⼹': {'number': 58, 'meaning': 'focinho de porco', 'variants': '彑'},
    '⼺': {'number': 59, 'meaning': 'cerda, barba'},

    '⼻': {'number': 60, 'meaning': 'passo'},
    '⼼': {'number': 61, 'meaning': 'coração, mente', 'variants': '忄、⺗'},
    '⼽': {'number': 62, 'meaning': 'lança'},
    '⼾': {'number': 63, 'meaning': 'porta, casa', 'variants': '户、戸'},
    '⼿': {'number': 64, 'meaning': 'mão', 'variants': '扌、龵'},
    '⽀': {'number': 65, 'meaning': 'ramo'},
    '⽁': {'number': 66, 'meaning': 'tocar, bater levemente', 'variants': '攵'},
    '⽂': {'number': 67, 'meaning': 'escrita, literatura'},
    '⽃': {'number': 68, 'meaning': 'objeto em forma de concha'},
    '⽄': {'number': 69, 'meaning': 'machado'},

    '⽅': {'number': 70, 'meaning': 'quadrado'},
    '⽆': {'number': 71, 'meaning': 'não, nada, negativo', 'variants': '旡'},
    '⽇': {'number': 72, 'meaning': 'sol, dia'},
    '⽈': {'number': 73, 'meaning': 'dizer, falar'},
    '⽉': {'number': 74, 'meaning': 'lua, mês'},
    '⽊': {'number': 75, 'meaning': 'árvore'},
    '⽋': {'number': 76, 'meaning': 'falta,'},
    '⽌': {'number': 77, 'meaning': 'parar'},
    '⽍': {'number': 78, 'meaning': 'morte, decadência', 'variants': '歺'},
    '⽎': {'number': 79, 'meaning': 'arma, lança'},

    '⽏': {'number': 80, 'meaning': 'mãe, não faça', 'variants': '母'},
    '⽐': {'number': 81, 'meaning': 'comparar, competir'},
    '⽑': {'number': 82, 'meaning': 'pelagem'},
    '⽒': {'number': 83, 'meaning': 'clã, linhagem'},
    '⽓': {'number': 84, 'meaning': 'ar, vapor, respiração'},
    '⽔': {'number': 85, 'meaning': 'água', 'variants': '氵、氺'},
    '⽕': {'number': 86, 'meaning': 'fogo', 'variants': '灬'},
    '⽖': {'number': 87, 'meaning': 'garra, unha', 'variants': '爫'},
    '⽗': {'number': 88, 'meaning': 'pai, luz'},
    '⽘': {'number': 89, 'meaning': 'duplo x, trigramas'},

    '⽙': {'number': 90, 'meaning': 'metade de um tronco, madeira rachada', 'variants': '丬'},
    '⽚': {'number': 91, 'meaning': 'fatia, filme'},
    '⽛': {'number': 92, 'meaning': 'dente, presa'},
    '⽜': {'number': 93, 'meaning': 'boi, vaca', 'variants': '牜、⺧'},
    '⽝': {'number': 94, 'meaning': 'cão', 'variants': '犭'},
    '⽞': {'number': 95, 'meaning': 'escuro, profundo'},
    '⽟': {'number': 96, 'meaning': 'jade', 'variants': '王、玊'},
    '⽠': {'number': 97, 'meaning': 'melão'},
    '⽡': {'number': 98, 'meaning': 'telha'},
    '⽢': {'number': 99, 'meaning': 'doce'},

    '⽣': {'number': 100, 'meaning': 'vida'},
    '⽤': {'number': 101, 'meaning': 'usar'},
    '⽥': {'number': 102, 'meaning': 'campo, arrozal'},
    '⽦': {'number': 103, 'meaning': 'pedaço de pano', 'variants': '⺪'},
    '⽧': {'number': 104, 'meaning': 'doença'},
    '⽨': {'number': 105, 'meaning': 'pegadas, pernas'},
    '⽩': {'number': 106, 'meaning': 'branco'},
    '⽪': {'number': 107, 'meaning': 'pele, couro'},
    '⽫': {'number': 108, 'meaning': 'prato'},
    '⽬': {'number': 109, 'meaning': 'olho', 'variants': '⺫'},

    '⽭': {'number': 110, 'meaning': 'lança'},
    '⽮': {'number': 111, 'meaning': 'seta, flecha'},
    '⽯': {'number': 112, 'meaning': 'pedra'},
    '⽰': {'number': 113, 'meaning': 'espírito, ancestral, veneração', 'variants': '礻'},
    '⽱': {'number': 114, 'meaning': 'trilha'},
    '⽲': {'number': 115, 'meaning': 'grão'},
    '⽳': {'number': 116, 'meaning': 'caverna'},
    '⽴': {'number': 117, 'meaning': 'ficar em pé, ereto'},
    '⽵': {'number': 118, 'meaning': 'bambu', 'variants': '⺮'},
    '⽶': {'number': 119, 'meaning': 'arroz'},

    '⽷': {'number': 120, 'meaning': 'seda', 'variants': '纟、糹'},
    '⽸': {'number': 121, 'meaning': 'pote, jarra'},
    '⽹': {'number': 122, 'meaning': 'rede', 'variants': '⺲、罓、⺳'},
    '⽺': {'number': 123, 'meaning': 'ovelha, cabra', 'variants': '⺶、⺷'},
    '⽻': {'number': 124, 'meaning': 'pena'},
    '⽼': {'number': 125, 'meaning': 'velho', 'variants': '耂'},
    '⽽': {'number': 126, 'meaning': 'e, mas'},
    '⽾': {'number': 127, 'meaning': 'arado'},
    '⽿': {'number': 128, 'meaning': 'orelha'},
    '⾀': {'number': 129, 'meaning': 'escova', 'variants': '⺺、⺻'},

    '⾁': {'number': 130, 'meaning': 'carne', 'variants': '月、⺼'},
    '⾂': {'number': 131, 'meaning': 'ministro, oficial'},
    '⾃': {'number': 132, 'meaning': 'próprio, auto-'},
    '⾄': {'number': 133, 'meaning': 'chegar'},
    '⾅': {'number': 134, 'meaning': 'argamassa, ligação'},
    '⾆': {'number': 135, 'meaning': 'língua'},
    '⾇': {'number': 136, 'meaning': 'opor'},
    '⾈': {'number': 137, 'meaning': 'barco'},
    '⾉': {'number': 138, 'meaning': 'parada, quietude'},
    '⾊': {'number': 139, 'meaning': 'cor, forma'},

    '⾋': {'number': 140, 'meaning': 'grama', 'variants': '⺿'},
    '⾌': {'number': 141, 'meaning': 'tigre'},
    '⾍': {'number': 142, 'meaning': 'inseto, verme'},
    '⾎': {'number': 143, 'meaning': 'sangue'},
    '⾏': {'number': 144, 'meaning': 'andar, ir, fazer'},
    '⾐': {'number': 145, 'meaning': 'roupa', 'variants': '⻂'},
    '⾑': {'number': 146, 'meaning': 'capa, oeste', 'variants': '西、覀'},
    '⾒': {'number': 147, 'meaning': 'ver', 'variants': '见'},
    '⾓': {'number': 148, 'meaning': 'chifre', 'variants': '⻆、⻇'},
    '⾔': {'number': 149, 'meaning': 'palavra, linguagem', 'variants': '讠、訁'},

    '⾕': {'number': 150, 'meaning': 'vale'},
    '⾖': {'number': 151, 'meaning': 'feijão, fava'},
    '⾗': {'number': 152, 'meaning': 'porco'},
    '⾘': {'number': 153, 'meaning': 'texugo, inseto sem pernas'},
    '⾙': {'number': 154, 'meaning': 'concha', 'variants': '贝'},
    '⾚': {'number': 155, 'meaning': 'vermelho, nu'},
    '⾛': {'number': 156, 'meaning': 'correr'},
    '⾜': {'number': 157, 'meaning': 'pé'},
    '⾝': {'number': 158, 'meaning': 'corpo'},
    '⾞': {'number': 159, 'meaning': 'carroça, carro', 'variants': '车'},

    '⾟': {'number': 160, 'meaning': 'amargo'},
    '⾠': {'number': 161, 'meaning': 'manhã'},
    '⾡': {'number': 162, 'meaning': 'caminhar', 'variants': '⻌、⻍、⻎'},
    '⾢': {'number': 163, 'meaning': 'cidade', 'variants': '⻏'},
    '⾣': {'number': 164, 'meaning': 'vinho, álcool'},
    '⾤': {'number': 165, 'meaning': 'distinto'},
    '⾥': {'number': 166, 'meaning': 'aldeia, vila'},
    '⾦': {'number': 167, 'meaning': 'ouro, metal', 'variants': '钅、釒'},
    '⾧': {'number': 168, 'meaning': 'longo, crescer', 'variants': '长、镸'},
    '⾨': {'number': 169, 'meaning': 'portão, porta', 'variants': '门'},

    '⾩': {'number': 170, 'meaning': 'monte, barragem', 'variants': '⻖'},
    '⾪': {'number': 171, 'meaning': 'escravo'},
    '⾫': {'number': 172, 'meaning': 'pássaro de cauda curta'},
    '⾬': {'number': 173, 'meaning': 'chuva'},
    '⾭': {'number': 174, 'meaning': 'azul, verde ou preto', 'variants': '青'},
    '⾮': {'number': 175, 'meaning': 'errado'},
    '⾯': {'number': 176, 'meaning': 'face', 'variants': '靣'},
    '⾰': {'number': 177, 'meaning': 'couro, couro cru'},
    '⾱': {'number': 178, 'meaning': 'couro tingido', 'variants': '韦'},
    '⾲': {'number': 179, 'meaning': 'alho-poró'},

    '⾳': {'number': 180, 'meaning': 'som'},
    '⾴': {'number': 181, 'meaning': 'folha, página', 'variants': '页'},
    '⾵': {'number': 182, 'meaning': 'vento', 'variants': '风'},
    '⾶': {'number': 183, 'meaning': 'voar', 'variants': '飞'},
    '⾷': {'number': 184, 'meaning': 'alimento, comer', 'variants': '饣、飠'},
    '⾸': {'number': 185, 'meaning': 'cabeça'},
    '⾹': {'number': 186, 'meaning': 'perfume, aroma'},
    '⾺': {'number': 187, 'meaning': 'cavalo', 'variants': '马'},
    '⾻': {'number': 188, 'meaning': 'osso', 'variants': ' ⻣'},
    '⾼': {'number': 189, 'meaning': 'alto', 'variants': '髙'},

    '⾽': {'number': 190, 'meaning': 'cabelo'},
    '⾾': {'number': 191, 'meaning': 'luta'},
    '⾿': {'number': 192, 'meaning': 'vinho sacrificial'},
    '⿀': {'number': 193, 'meaning': 'caldeirão, tripé'},
    '⿁': {'number': 194, 'meaning': 'fantasma, demônio'},
    '⿂': {'number': 195, 'meaning': 'peixe', 'variants': '鱼'},
    '⿃': {'number': 196, 'meaning': 'pássaro', 'variants': '鸟'},
    '⿄': {'number': 197, 'meaning': 'sal', 'variants': '卤'},
    '⿅': {'number': 198, 'meaning': 'corça, veado'},
    '⿆': {'number': 199, 'meaning': 'trigo', 'variants': '麦'},

    '⿇': {'number': 200, 'meaning': 'cânhamo, linho'},
    '⿈': {'number': 201, 'meaning': 'amarelo', 'variants': '黄'},
    '⿉': {'number': 202, 'meaning': 'milhete, painço'},
    '⿊': {'number': 203, 'meaning': 'preto'},
    '⿋': {'number': 204, 'meaning': 'bordado'},
    '⿌': {'number': 205, 'meaning': 'sapo, anfíbio', 'variants': '黾'},
    '⿍': {'number': 206, 'meaning': 'tripé de sacrifício, caldeirão de três pernas'},
    '⿎': {'number': 207, 'meaning': 'tambor'},
    '⿏': {'number': 208, 'meaning': 'rato, camundongo', 'variants': '鼡'},
    '⿐': {'number': 209, 'meaning': 'nariz'},

    '⿑': {'number': 210, 'meaning': 'mesmo, uniformemente', 'variants': '齐、斉'},
    '⿒': {'number': 211, 'meaning': 'dente', 'variants': '齿'},
    '⿓': {'number': 212, 'meaning': 'dragão', 'variants': '龙'},
    '⿔': {'number': 213, 'meaning': 'tartaruga', 'variants': '龟'},
    '⿕': {'number': 214, 'meaning': 'flauta'}
}


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


def write_radicals(readdir, writedir):
    global entries
    nof_entries = len(entries)
    print(f'NofEntries = {nof_entries}')
    allentries = []
    radicals = {}
    last_radicals = ''
    last_first_hanzi = ''
    for entry in entries:
        print(f'Processing entry {entry[0]}')
        filename = '~'.join(list(entry)) + '.tex'
        allentries.append(filename)
        first_radicals = entry[0]
        if last_radicals != first_radicals:
            last_radicals = first_radicals
            print(f'Genenerating Radicals {first_radicals}')
        if first_radicals not in radicals:
            radicals[first_radicals] = list()
        radicals[first_radicals].append(filename)
    for r in radicals:
        filename = writedir + '/' + r + '.tex'
        radical_str = ""
        radical_toc_str = ""
        number = kangxi[r]['number']
        radical_str = f"Radical {number:d}: ``{r}''"
        radical_toc_str = f"Radical {number:d}: {r}"
        if 'variants' in kangxi[r]:
            print(f'Writting Radicals {filename}')
            variants = kangxi[r]['variants']
            radical_str += f" ({variants})"
            radical_toc_str += f"、{variants}"

        print(f'Writting Radicals {filename}')
        with open(filename, 'w', encoding='utf-8') as file:
            file.write('%%%\n')
            file.write(f'%%% Radical "{r}"\n')
            file.write('%%%\n')
            file.write(f'\\section*{{{radical_str}}}')
            file.write(f'\\addcontentsline{{toc}}{{section}}{{{radical_toc_str}}}\n\n')

            for e in radicals[r]:
                first_hanzi = e.split('.', 1)[0].split('~')[2]
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
        pelos radicais''')
    parser.add_argument('--version', '-V', action='version', version=f'%(prog)s v{VERSION}')
    parser.add_argument('--read', '--readdir', '-r', dest='read_dir', action='store')
    parser.add_argument('--write', '--writedir', '-w', dest='write_dir', action='store')
    args = parser.parse_args()
    get_entries(args.read_dir)
    write_radicals(args.read_dir, args.write_dir)
    return 0


if __name__ == "__main__":
    errno = main()
    sys.exit(errno)
