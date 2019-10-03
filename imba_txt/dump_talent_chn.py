import os
import random
import re
import fileinput
import requests
os.chdir('E:/imba_txt/')
print(os.getcwd())

if not os.path.exists('addon_schinese.txt'): # 看一下这个文件是否存在
	input("none")
	exit(-1) #，不存在就退出

i=0

with open('addon_schinese.txt', mode='r', encoding='utf-16') as file, open('talent_chn.txt', mode='w', encoding='utf-8') as fp:
	for line in file:
		i = i + 1
		print(i)
		if re.search('DOTA_Tooltip_ability_special_bonus_', line, re.IGNORECASE):
			print(line)
			fp.write(line.replace('%%', '%'))
fp.close() # 关闭文件
os.remove('addon_schinese.txt')
input("done!")