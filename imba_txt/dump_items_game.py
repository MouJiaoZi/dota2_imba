import os
import random
import re
import fileinput
os.chdir('E:/imba_txt/')
print(os.getcwd())

import requests 
url = 'https://raw.githubusercontent.com/SteamDatabase/GameTracking-Dota2/master/game/dota/pak01_dir/scripts/items/items_game.txt' 
r = requests.get(url) 
with open("items_game.txt", "wb") as code:
    code.write(r.content)

if not os.path.exists('items_game.txt'): # 看一下这个文件是否存在
	input("none")
	exit(-1) #，不存在就退出

#lines = open('imba_item_info.txt').readlines() #打开文件，读入每一行
#f = open('imba_item_info.txt','r')
#fp = open('b.txt','w') #打开你要写得文件pp2.txt
i=0

with open('items_game.txt', mode='r', encoding='utf-8') as file, open('icon_info.txt', mode='w', encoding='utf-8') as fp:
	for line in file:
		i = i + 1
		print(i)
		tt = random.randrange(0,100000)
		tem = '%d' %tt
		fp.write(line.replace('asset_modifier',tem)) # replace是替换，write是写入
fp.close() # 关闭文件
os.remove('items_game.txt')
input("done!")