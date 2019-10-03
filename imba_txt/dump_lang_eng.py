import os
import random
import re
import fileinput
import requests
os.chdir('E:/imba_txt/')
print(os.getcwd())

import requests 
url = 'https://raw.githubusercontent.com/SteamDatabase/GameTracking-Dota2/master/game/dota/pak01_dir/resource/localization/abilities_english.txt' 
r = requests.get(url) 
with open("abilities_english.txt", "wb") as code:
    code.write(r.content)
	
if not os.path.exists('abilities_english.txt'): # 看一下这个文件是否存在
	input("none")
	exit(-1) #，不存在就退出

i=0

with open('abilities_english.txt', mode='r', encoding='utf-8') as file, open('lang_eng.txt', mode='w', encoding='utf-8') as fp:
	for line in file:
		i = i + 1
		print(i)
		if re.search('DOTA_Tooltip_ability_special_bonus_', line, re.IGNORECASE):
			print(line)
			fp.write(line)
fp.close() # 关闭文件
os.remove('abilities_english.txt')
input("done!")