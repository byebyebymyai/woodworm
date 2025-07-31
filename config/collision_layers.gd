extends Node2D

# 层级定义（使用位运算）
const GROUND = 1 << 0 # 第1层: 地面
const WALLS = 1 << 1 # 第2层: 墙壁
const PLAYER = 1 << 2 # 第3层: 玩家
const ENEMY = 1 << 3 # 第4层: 敌人
const PROJECTILE = 1 << 4 # 第5层: 抛射物
const PICKUP = 1 << 5 # 第6层: 拾取物

# 组合掩码 - 常用的检测组合
const SOLID_OBJECTS = GROUND | WALLS | PICKUP
const LIVING_ENTITIES = PLAYER | ENEMY
const ALL = GROUND | WALLS | PLAYER | ENEMY | PROJECTILE | PICKUP
const ALL_BLOCKS = WALLS | PICKUP
const ALL_EXCEPT_PLAYER = GROUND | ENEMY | PROJECTILE | PICKUP | WALLS