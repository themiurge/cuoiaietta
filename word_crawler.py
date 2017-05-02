# coding: utf-8
import requests
import string

LETTER_URL = 'http://dizionari.corriere.it/dizionario_italiano/{}.shtml'
WORD_URL = 'http://dizionari.corriere.it/dizionario_italiano/{}/{}.shtml'
FIRST_WORD = '<li><a href="{}/'
CURRENT_WORD = 'class="def-attivo"'
NEXT_WORD = '<li><a href="'
WORD_FILE = 'words/{}.txt'
DEF_START = '<div id="defin-dx"'
DEF_END = '</div>'

word_id = 1


def crawl_word(uc, url):
    global word_id
    done = False
    while not done:
        print(url, "-->", end=' ', flush=True)
        try:

            r = requests.get(url, timeout=10)
            done = True
            if r.status_code == 200:
                print("OK")

                # save current word
                d = r.text.find(DEF_START)
                if d < 0:
                    print("UNEXPEXTED ERROR at {}".format(url))
                else:
                    d_count = r.text.find(DEF_END, d) - d + len(DEF_END)
                    to_save = r.text[d : d+d_count]
                    with open(WORD_FILE.format(word_id), 'w') as f:
                        f.write(to_save)
                    word_id += 1

                # find next word (if any)
                start_pos = r.text.find(CURRENT_WORD)
                cur_newline = r.text.find('\n', start_pos)
                next_newline = r.text.find('\n', cur_newline+1)
                next_word_start = r.text.find(NEXT_WORD, cur_newline+1, next_newline)
                if next_word_start >= 0:
                    start_index = next_word_start + len(NEXT_WORD)
                    count = r.text.find('.shtml', start_index) - start_index
                    link = r.text[start_index : start_index+count]
                    return WORD_URL.format(uc, link)
            else:
                print("not found")
                
        except:
            print("retry")
            pass
    return ""

urls = []

print("Collecting base URLs...", flush=True)

for lc, uc in zip(string.ascii_lowercase, string.ascii_uppercase):
    print('.', end='', flush=True)
    r = requests.get(LETTER_URL.format(lc))
    print('.', end='', flush=True)
    to_find = FIRST_WORD.format(uc)
    start_index = r.text.find(to_find) + len(to_find)
    count = r.text.find('.shtml', start_index) - start_index
    link = r.text[start_index : start_index+count]
    url = WORD_URL.format(uc, link)
    urls.append((uc, url))

print("\ndone. Now crawling URLs...", flush=True)

for uc, url in urls:
    next_url = crawl_word(uc, url)
    while next_url:
        next_url = crawl_word(uc, next_url)
