-- 一个伪随机数生成算法
-- 从下面的这个js代码改写而来的
-- https://jsbin.com/nifutup/1/edit?js,output
-- XavierCHN @ 2018.8

PseudoRandom = class({})

function PseudoRandom:constructor()
	self.a = 1664525
	self.c = 1013904223
	self.m = 2 ^ 32
	self.seed = RandomInt(1, 999999)
end

function PseudoRandom:NextRand()
	self.seed = (self.a * self.seed + self.c) % self.m
	return self.seed
end

function PseudoRandom:NextFloat(min, max)
	return min + (max - min) * self:NextRand() / self.m
end

function PseudoRandom:NextInt(min, max)
	return min + math.floor(self:NextFloat() * (max - min + 1))
end

PseudoRandom:constructor()

-- Usage
-- local pseudo_random = PesudoRandom()
-- local int = pseudo_random:NextInt(1, 100)