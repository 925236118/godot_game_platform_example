# godot_game_platform_example

用于测试Godot常见游戏架构的仓库。基于 Obsidian 笔记库中的 32 篇架构笔记，每个示例从 `master` 分支创建独立分支开发，互不影响。

> **开发环境**: Godot 4.6 / Forward Plus
> **资源说明**: 所有示例使用 `icon.svg` 或 ColorRect 彩色方块替代纹理

---

## 分支列表

| 分支名 | 玩法类型 | 核心架构要点 |
|--------|---------|-------------|
| `feature-2d-shooter` | 2D射击游戏 | 射击系统、敌人AI、碰撞检测、关卡波次 |
| `feature-action-rpg` | 动作RPG | 即时战斗、装备系统、技能树、属性成长 |
| `feature-battle-royale` | 大逃杀游戏 | 缩圈机制、空投系统、多人在线框架 |
| `feature-board-game` | 棋类游戏 | 回合制逻辑、AI对手、棋盘状态管理 |
| `feature-bullet-hell` | 弹幕射击游戏 | 弹幕模式生成、碰撞判定、BOSS战设计 |
| `feature-card-game` | 卡牌类游戏 | 卡牌数据驱动、手牌管理、对战逻辑 |
| `feature-clicker` | 点击游戏 | 数值膨胀模型、自动产出、升级树 |
| `feature-desktop-pet` | 桌宠游戏 | AI行为、交互反馈、桌面集成 |
| `feature-farming` | 种植类游戏 | 作物生长系统、季节机制、工具系统 |
| `feature-fighting` | 格斗游戏 | 帧精确输入、连招系统、受击硬直 |
| `feature-fps` | 3D第一人称射击 | 3D射击、枪械系统、弹药管理、敌人AI |
| `feature-idle` | 放置类游戏 | 离线收益、升级链、解锁机制 |
| `feature-match-three` | 消除类游戏 | 棋盘匹配算法、连击判定、关卡设计 |
| `feature-metroidvania` | 银河城游戏 | 开放式地图、能力锁、回溯探索 |
| `feature-pet-battle` | 精灵对战游戏 | 宠物收集、属性克制、技能池 |
| `feature-platformer` | 平台跳跃游戏 | 状态机、物理跳跃、平台碰撞、关卡设计 |
| `feature-puzzle` | 解谜游戏 | 谜题状态管理、交互反馈、关卡链 |
| `feature-racing` | 赛车竞速游戏 | 物理驾驶、赛道系统、AI对手、计时 |
| `feature-rhythm-game` | 音游 | 节奏判定、谱面系统、视觉反馈 |
| `feature-roguelike` | 肉鸽游戏 | 随机生成、永久死亡、成长构筑 |
| `feature-runner` | 跑酷游戏 | 自动奔跑、障碍生成、无尽模式 |
| `feature-sandbox-building` | 沙盒建造游戏 | 方块放置/破坏、地形修改、物品栏 |
| `feature-social-deduction` | 社交推理游戏 | 角色分配、投票系统、回合讨论 |
| `feature-stealth` | 潜行类游戏 | 视野系统、警戒值、潜行机制 |
| `feature-survival` | 生存类游戏 | 资源管理、合成系统、昼夜循环 |
| `feature-tactical-rpg` | 战棋游戏 | 网格移动、行动顺序、地形加成 |
| `feature-tower-defense` | 塔防游戏 | 路径系统、防御塔、敌人波次 |
| `feature-turn-based-combat` | 回合制战斗 | ATB/CTB系统、技能冷却、状态效果 |
| `feature-turn-based-rpg` | 回合制RPG | 队伍系统、迷宫探索、剧情驱动 |
| `feature-tycoon` | 模拟经营游戏 | 经济系统、升级链、顾客AI |
| `feature-vampire-survivor` | 吸血鬼幸存者类 | 自动攻击、经验升级、武器进化 |
| `feature-visual-novel` | 视觉小说游戏 | 分支对话、好感度、CG系统 |

---

## 开发中 / 已完成

| 分支 | 状态 | 简要说明 |
|------|------|---------|
| `feature-platformer` | 🚧 进行中 | — |
| `feature-action-rpg` | 🚧 进行中 | — |
| `feature-vampire-survivor` | 🚧 进行中 | — |

> 状态标记: ✅ 已完成 · 🚧 进行中 · ⬜ 待开始

---

## 目录模板

项目采用扁平化结构，参考 Godot 默认游戏目录模板（笔记 `Godot-默认游戏目录模板.md`）：

```
示例项目/
├── assets/              # 资源（字体、音效等纯占位资源可省略）
├── globals/             # 全局单例脚本
├── scenes/              # 游戏场景
├── scripts/             # 脚本文件
│   ├── classes/         # 自定义类
│   └── components/      # 可复用组件
├── project.godot        # 项目配置
└── icon.svg             # 项目图标
```
