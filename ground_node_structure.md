# 地面系统节点结构设计 (瓦片纹理版)

## 主要地面系统 - 使用 TileMap

```
TerrainSystem (Node2D)
├── GroundTileMap (TileMap)             # 主地面瓦片层
├── WoodTileMap (TileMap)               # 木头瓦片层
├── WallTileMap (TileMap)               # 墙壁瓦片层
└── InteractiveObjects (Node2D)        # 特殊交互对象层
    ├── Wood001 (Wood)                 # 独立的木头对象
    ├── Wood002 (Wood)
    └── ...
```

## TileSet 资源配置

### 地面瓦片集 (GroundTileSet.tres)

```
TileSet资源包含：
├── 基础地面瓦片 (Physics Layer 0)
│   ├── 草地瓦片
│   ├── 泥土瓦片
│   ├── 石头瓦片
│   └── 各种地形变体
├── 木头瓦片 (Physics Layer 1)
│   ├── 软木瓦片
│   ├── 硬木瓦片
│   ├── 腐木瓦片
│   └── 木头变体
└── 墙壁瓦片 (Physics Layer 2)
    ├── 石墙瓦片
    ├── 木墙瓦片
    └── 可攀爬墙壁
```

## TileMap 层级设置

### GroundTileMap 配置

```
TileMap属性：
- TileSet: GroundTileSet.tres
- Physics Layer 0: collision_layer = 2, collision_mask = 0
- Rendering Layer 0: z_index = 0
- 用于普通地面碰撞
```

### WoodTileMap 配置

```
TileMap属性：
- TileSet: GroundTileSet.tres
- Physics Layer 1: collision_layer = 3, collision_mask = 0
- Rendering Layer 0: z_index = 1
- 自定义数据层添加：
  - wood_type (int): 0=软木, 1=硬木, 2=腐木
  - eat_duration (float): 吃掉所需时间
  - nutrition_value (int): 营养价值
```

### WallTileMap 配置

```
TileMap属性：
- TileSet: GroundTileSet.tres
- Physics Layer 2: collision_layer = 2, collision_mask = 0
- Rendering Layer 0: z_index = 2
- 自定义数据层添加：
  - climbable (bool): 是否可攀爬
  - surface_type (int): 表面类型
```

## 混合系统 - 瓦片 + 独立对象

### 何时使用瓦片

- 大面积重复地形（地面、基础墙壁）
- 静态不变的环境元素
- 需要自动瓦片连接的区域

### 何时使用独立对象

- 需要复杂交互的木头（特殊动画、音效）
- 可移动或可破坏的元素
- 需要独特行为的特殊地形

## 复合地形节点 (TerrainBlock.tscn)

```
TerrainBlock (StaticBody2D)
├── CollisionShape2D                    # 主碰撞体
├── TerrainSprite (Sprite2D)           # 地形外观
├── TopSurface (Area2D)                # 顶部表面（可站立）
│   └── CollisionShape2D
├── LeftSurface (Area2D)               # 左侧表面（可攀爬）
│   └── CollisionShape2D
├── RightSurface (Area2D)              # 右侧表面（可攀爬）
│   └── CollisionShape2D
├── BottomSurface (Area2D)             # 底部表面（可倒挂）
│   └── CollisionShape2D
└── TerrainProperties (Node)           # 地形属性
```

## 完整关卡场景结构 (瓦片版)

```
Level (Node2D)
├── Background (ParallaxBackground)    # 背景层
├── TerrainSystem (Node2D)             # 地形系统
│   ├── GroundTileMap (TileMap)        # 基础地面瓦片
│   ├── WoodTileMap (TileMap)          # 木头瓦片
│   ├── WallTileMap (TileMap)          # 墙壁瓦片
│   └── DecorationTileMap (TileMap)    # 装饰瓦片（无碰撞）
├── InteractiveObjects (Node2D)        # 特殊交互对象
│   ├── SpecialWood001 (Wood)          # 特殊木头
│   ├── MovingPlatform001 (MovingPlatform)
│   └── ...
├── Woodworm (Woodworm)                # 虫子
└── UI (CanvasLayer)                   # 用户界面
```

## 物理层配置

### 碰撞层设置

```
Layer 1: 虫子主体 (Woodworm)
Layer 2: 地面 (Ground, Wall, TerrainBlock)
Layer 3: 木头主体 (Wood)
Layer 4: 虫子地面检测器
Layer 5: 虫子前方检测器
Layer 6: 虫子墙壁检测器
Layer 7: 木头可食用区域
Layer 8: 墙壁可攀爬区域
```

### 碰撞掩码设置

```
虫子主体: 检测 Layer 2, 3 (地面和木头)
虫子地面检测器: 检测 Layer 2 (地面)
虫子前方检测器: 检测 Layer 3, 7 (木头)
虫子墙壁检测器: 检测 Layer 8 (可攀爬区域)
```

## 节点组 (Groups) 设置

### 地面相关组

```
"ground" - 所有地面类型
"solid_ground" - 固体地面
"soft_ground" - 可挖掘地面
```

### 木头相关组

```
"edible_wood" - 可食用木头
"soft_wood" - 软木（快速吃掉）
"hard_wood" - 硬木（慢速吃掉）
"rotten_wood" - 腐木（瞬间吃掉）
```

### 墙壁相关组

```
"climbable_wall" - 可攀爬墙壁
"smooth_wall" - 光滑墙壁（不可攀爬）
"rough_wall" - 粗糙墙壁（易攀爬）
```

## 虫子与瓦片交互系统

### 检测瓦片信息的方法

```gdscript
# 在虫子脚本中检测瓦片信息
func check_tile_at_position(pos: Vector2, tilemap: TileMap):
    var tile_pos = tilemap.local_to_map(pos)
    var tile_data = tilemap.get_cell_tile_data(0, tile_pos)

    if tile_data:
        # 获取自定义数据
        var wood_type = tile_data.get_custom_data("wood_type")
        var eat_duration = tile_data.get_custom_data("eat_duration")
        var climbable = tile_data.get_custom_data("climbable")
        return tile_data
    return null

# 吃掉木头瓦片
func eat_wood_tile(tilemap: TileMap, tile_pos: Vector2i):
    # 移除瓦片
    tilemap.set_cell(0, tile_pos, -1)
    # 播放吃掉效果
    play_eating_effect()
```

### TileMap 管理器脚本

```gdscript
extends Node2D
class_name TerrainManager

@onready var wood_tilemap = $WoodTileMap
@onready var ground_tilemap = $GroundTileMap
@onready var wall_tilemap = $WallTileMap

func get_tile_info_at_position(world_pos: Vector2):
    # 检查所有图层的瓦片信息
    var wood_data = check_wood_tile(world_pos)
    var ground_data = check_ground_tile(world_pos)
    var wall_data = check_wall_tile(world_pos)

    return {
        "wood": wood_data,
        "ground": ground_data,
        "wall": wall_data
    }

func remove_wood_tile(world_pos: Vector2):
    var tile_pos = wood_tilemap.local_to_map(world_pos)
    wood_tilemap.set_cell(0, tile_pos, -1)
```

## 特殊地形类型

### 1. 可破坏地面

```
BreakableGround (StaticBody2D)
├── CollisionShape2D
├── GroundSprite (Sprite2D)
├── BreakEffect (Node2D)
│   └── Particles (CPUParticles2D)
└── HealthComponent (Node)              # 耐久度系统
```

### 2. 移动平台

```
MovingPlatform (AnimatableBody2D)       # 使用AnimatableBody2D支持移动
├── CollisionShape2D
├── PlatformSprite (Sprite2D)
└── MovementPath (Path2D)               # 移动路径
    └── PathFollow2D
```

### 3. 一次性平台

```
OneTimePlatform (StaticBody2D)
├── CollisionShape2D
├── PlatformSprite (Sprite2D)
├── FallTimer (Timer)                   # 踩踏后倒计时
└── FallTween (Tween)                   # 下落动画
```

## 关卡设计建议

### 网格系统

- 使用 64x64 像素的网格
- 所有地形元素对齐到网格
- 便于关卡编辑器设计

## 瓦片系统的优势

### 性能优势

- **批量渲染**: 同类瓦片一次性渲染，性能更好
- **内存效率**: 重复瓦片共享纹理资源
- **大型关卡**: 轻松创建大规模关卡

### 编辑优势

- **自动瓦片**: 支持智能瓦片连接
- **快速绘制**: 使用画刷工具快速构建地形
- **规则瓦片**: 自动处理边角和连接

### 地形组合策略

```
基础地面瓦片 + 木头瓦片层 = 丰富的可食用环境
墙壁瓦片 + 攀爬数据 = 立体移动空间
装饰瓦片 + 背景 = 视觉层次感
混合独立对象 = 特殊交互区域
```

## 实现注意事项

### 瓦片碰撞优化

- 使用 `collision_layer` 分离不同类型瓦片
- 避免不必要的碰撞检测
- 合理设置 `collision_mask`

### 自定义数据管理

- 在 TileSet 中预先配置所有自定义数据
- 使用统一的数据命名规范
- 建议数据类型和默认值

### 动态瓦片修改

- 使用 `set_cell()` 动态移除被吃掉的木头
- 考虑瓦片移除后的连接更新
- 保存关卡状态用于存档系统

这种瓦片系统设计既保持了高性能，又支持虫子游戏的复杂交互需求，为大型关卡开发提供了坚实基础。
