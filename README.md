# Platformer Example — 平台跳跃游戏架构

基于 Obsidian 笔记库 `Godot-平台跳跃类游戏架构.md` 的可运行示例。

> **Godot版本**: 4.6 / Forward Plus
> **分支**: `feature-platformer`
> **控制**: A/D 移动 · W/空格 跳跃 · Shift 冲刺 · ESC 暂停

---

## 玩法说明

经典2D横版平台跳跃游戏，玩家控制角色在平台间跳跃移动，收集金币、躲避尖刺、踩扁敌人，到达关卡终点。

- **移动与跳跃**: 支持可变跳跃高度（轻按/长按）、Coyote Time（离地缓冲）、Jump Buffer（预输入缓冲）
- **二段跳**: 最多可空中额外跳跃1次
- **冲刺**: 地面/空中均可冲刺，冲刺期间无敌
- **蹬墙跳**: 贴墙时按跳跃可反向弹墙
- **生命系统**: 3格血量，受伤无敌时间+闪烁反馈
- **收集品**: 金币+分数奖励
- **敌人**: 巡逻型敌人，可踩杀

---

## 核心架构

```
scenes/
├── Main.tscn             # 根场景：组合关卡+HUD
├── Level.tscn             # 关卡场景：地形+玩家+敌人+收集品
├── Player.tscn            # 玩家预制体
├── Coin.tscn              # 金币预制体
├── PatrolEnemy.tscn       # 巡逻敌人预制体
└── Spikes.tscn            # 尖刺机关预制体

scripts/
├── Player.gd              # 玩家控制器：状态机+物理+能力系统
├── PlatformCamera.gd      # 相机系统：平滑跟随+视线提前+震屏
├── Coin.gd                # 金币收集品
├── PatrolEnemy.gd         # 巡逻敌人AI
├── Spikes.gd              # 尖刺伤害区域
├── HUD.gd                 # 头像显示与暂停/死亡界面
└── OneWayPlatform.gd      # 单向平台组件

globals/
└── GameManager.gd         # 全局游戏状态管理器 (Autoload)
```

### 关键设计

**1. 状态机驱动的玩家控制器**
- 状态枚举：IDLE, RUNNING, JUMP, FALL, WALL_SLIDING, WALL_JUMP, DASHING, HURT, DEAD
- 所有能力（跳跃、冲刺、蹬墙跳）统一通过状态机流转触发
- 物理参数全部 `@export` 暴露，可在编辑器中按需调整

**2. 高阶跳跃技巧**
- **Coyote Time**: 离开地面后 0.1s 内仍可跳跃，容错宽松
- **Jump Buffer**: 落地前 0.1s 内输入跳跃可被缓存，落地即跳
- **可变跳跃高度**: 松开跳跃键截断上升速度（×0.5）

**3. 分层碰撞系统**
- Layer 1: 关卡地形（地面、平台、墙壁）
- Layer 2: 玩家角色
- Layer 3: 敌人
- Area2D 用于触发器（金币、尖刺）

---

## 笔记验证结论

**准确度**: ✅ 笔记中状态机设计、物理参数、碰撞分层与实际实现高度一致
**实用性**: ✅ 控制器脚本可直接复用，参数化程度高
**扩展性**: ✅ 新增能力（飞行、攀爬、下劈）只需扩展状态枚举+handler方法
