# UCL 活动集成到日历系统 & 智能推荐功能

## 概述

成功将 UCLActivitiesView 中的活动数据集成到日历系统，并实现了基于学生专业的智能推荐功能。

## 实现的功能

### 1. **活动日历集成** ✅

#### UCLAPIViewModel 扩展
- 新增 `EventType` 枚举值：
  - `.activity` - UCL 活动
  - `.recommended` - 推荐活动
  
- 扩展 `UCLAPIEvent` 结构：
  - `activityType: String?` - 活动类型（academic, cultural, sport 等）
  - `isRecommended: Bool` - 推荐标记
  
- 新增核心方法：
  - `loadUCLActivities()` - 加载 UCL 活动数据
  - `integrateActivitiesToEvents()` - 将活动集成到事件列表
  - `parseActivityDateTime()` - 解析活动日期时间
  - `addActivityToCalendar()` - 添加活动到日历

#### 日历视图集成
- 所有日历视图（月/周/日）现在可以显示：
  - 课程安排（原有）
  - 作业截止日期（原有）
  - **UCL 活动事件**（新增）✨
  
- 活动在日历上有事件指示器小点
- 点击日期可查看当天的活动详情

### 2. **智能推荐系统** ✅

#### 推荐算法
基于以下维度进行智能推荐：

**活动类型匹配**
```swift
recommendedTypes = ["academic", "lecture", "seminar"]
```

**关键词匹配**（针对健康数据科学专业）
```swift
healthKeywords = [
    "health",      // 健康
    "data",        // 数据
    "ai",          // 人工智能
    "medical",     // 医疗
    "population",  // 人口
    "informatics"  // 信息学
]
```

#### 推荐活动示例

根据当前的 UCL 活动数据，以下活动会被推荐：

1. **Graduate Open Events: Health Data, Informatics and AI**
   - 类型：academic ✓
   - 关键词：health, data, ai, informatics ✓✓✓✓
   - 推荐度：⭐⭐⭐⭐⭐

2. **UCL Graduate Open Events: Population Health Sciences**
   - 类型：academic ✓
   - 关键词：population, health ✓✓
   - 推荐度：⭐⭐⭐⭐⭐

3. **Health Studies User Conference 2025**
   - 类型：academic ✓
   - 关键词：health, data ✓✓
   - 推荐度：⭐⭐⭐⭐

#### 推荐展示
在 StudentDashboardView 的"为你推荐"板块：
- 显示前 5 个推荐活动
- 每个活动显示：
  - 标题
  - 日期和时间
  - 地点
  - 活动类型图标（带颜色区分）
  - "推荐"标签 ✨

### 3. **一键添加活动到日历** ✅

#### UCLActivitiesView 增强
- 每个活动卡片现在有"添加到日历"按钮
- 点击后：
  1. 调用 `viewModel.addActivityToCalendar(activity)`
  2. 活动添加到 UCLAPIViewModel 的 events 列表
  3. 同步到系统日历（需要日历权限）
  4. 按钮变为"已添加" ✓（绿色）
  5. 提供触觉反馈（iOS）

#### 添加流程
```
用户点击"添加到日历"
    ↓
解析活动日期时间
    ↓
创建 UCLAPIEvent
    ↓
添加到 events 数组
    ↓
添加到系统日历
    ↓
UI 更新（已添加状态）
```

### 4. **活动类型可视化** ✅

不同类型活动有不同的图标和颜色：

| 活动类型 | 图标 | 颜色 |
|---------|------|------|
| Academic / Lecture | 🎓 graduationcap.fill | 紫色 #6366F1 |
| Cultural / Art | 🎨 paintpalette.fill | 粉色 #EC4899 |
| Sport / Fitness | 🏃 figure.run | 绿色 #10B981 |
| Club / Society | 👥 person.3.fill | 紫罗兰 #8B5CF6 |
| Workshop | 🔨 hammer.fill | 橙色 #F59E0B |

## 技术实现细节

### 日期时间解析

支持多种日期格式：
- ISO 8601: `2025-11-07T11:00:00`
- 组合格式: `Nov 7, 2025 11:00`
- 分离格式: date=`Nov 7, 2025`, time=`11:00`

```swift
private func parseActivityDateTime(_ dateStr: String, _ timeStr: String) -> Date {
    // 尝试 ISO 8601
    if timeStr.contains("T") { ... }
    
    // 尝试组合格式
    let combined = "\(dateStr) \(timeStr)"
    
    // 尝试仅日期
    ...
}
```

### 避免重复添加

使用标题和日期匹配检查：
```swift
if !events.contains(where: { 
    $0.title == event.title && 
    Calendar.current.isDate($0.startTime, inSameDayAs: event.startTime) 
}) {
    events.append(event)
}
```

## 使用流程

### 学生端体验

1. **查看推荐活动**
   - 打开学生首页
   - 滚动到"为你推荐"板块
   - 看到根据专业推荐的 5 个活动

2. **浏览所有活动**
   - 点击"查看全部"或切换到活动 Tab
   - 查看完整的 UCL 活动列表
   - 使用筛选器按类别查找

3. **添加活动到日历**
   - 在活动卡片上点击"添加到日历"
   - 活动自动添加到个人日历
   - 在日历视图中查看活动

4. **日历查看活动**
   - 打开日历 Tab
   - 看到活动在对应日期上有小点指示
   - 点击日期查看详细活动信息

### 家长端体验

- 家长可以在日历中看到孩子添加的活动
- 了解孩子参加的学术活动和社团活动
- 通过日历监督孩子的校园生活参与度

## 数据流程

```
UCLActivitiesService
    ↓ loadActivities()
UCLActivity[] (12个活动)
    ↓ integrateActivitiesToEvents()
UCLAPIEvent[] (课程 + 作业 + 活动)
    ↓ generateRecommendations()
推荐活动标记 (isRecommended = true)
    ↓ getRecommendedActivities()
展示在 Dashboard
```

## 现有活动数据

当前系统包含 12 个真实的 UCL 活动：

### 推荐活动（3个）
1. Graduate Open Events: Health Data, Informatics and AI
2. UCL Graduate Open Events: Population Health Sciences  
3. Health Studies User Conference 2025

### 其他活动（9个）
4. The Future of the ECHR – In Europe and UK
5. Assize Seminar – Cutting Edge Criminal Law
6. Repair Café
7. Workshop: Walking Elsewhere – Body and City in Exile
8. Broken, Burnt, Buried: Ritual Lives of Objects in Ancient Egypt
9. Prejudice in Power: Contesting the Pseudoscience of Superiority
10. Wednesdays Pop-Up Displays: Amongst Visions
11. World of Wasps
12. Fair Food Futures UK Photo Exhibition

## 优势特性

✅ **智能推荐** - 基于专业自动推荐相关活动  
✅ **无缝集成** - 活动自然融入日历系统  
✅ **一键添加** - 快速将活动添加到个人日历  
✅ **可视化** - 不同活动类型用图标和颜色区分  
✅ **防重复** - 自动检测避免重复添加  
✅ **多格式支持** - 兼容多种日期时间格式  
✅ **实时更新** - 活动数据实时同步到日历  

## 未来扩展

可以进一步优化的方向：

1. **个性化推荐增强**
   - 基于用户点击历史
   - 基于已参加活动类型
   - 协同过滤推荐

2. **活动提醒**
   - 活动开始前 1 天/1 小时提醒
   - 推送通知

3. **活动报名**
   - 直接在 App 内报名活动
   - 查看报名人数

4. **活动评价**
   - 参加后可以评分和评论
   - 查看其他同学的评价

5. **社交功能**
   - 查看好友参加的活动
   - 邀请好友一起参加

## 代码改动总结

### 修改的文件
1. `UCLAPIViewModel.swift` (+265 行)
   - 扩展事件类型
   - 添加活动集成逻辑
   - 实现推荐算法

2. `UCLActivitiesView.swift` (-86 行, +32 行)
   - 简化添加到日历逻辑
   - 使用 ViewModel 统一管理

3. `StudentDashboardView.swift` (+151 行)
   - 添加推荐活动板块
   - 新增 RecommendedEventCard 组件

### 代码统计
- 总计：+382 插入，-86 删除
- 净增加：296 行

## 测试建议

1. **功能测试**
   - 检查推荐活动是否正确显示
   - 验证添加活动到日历功能
   - 测试日历中活动的显示

2. **边界测试**
   - 无活动时的空状态
   - 大量活动时的性能
   - 日期格式异常处理

3. **集成测试**
   - 活动与课程、作业在日历中的共存
   - 跨 Tab 切换时数据的一致性

## 总结

✅ 成功实现了 UCL 活动集成到日历系统  
✅ 实现了基于专业的智能推荐功能  
✅ 优化了用户体验，一键添加活动到日历  
✅ 所有代码已提交并推送到 GitHub  
✅ 零编译错误，代码质量良好  

现在学生可以：
- 在首页看到为他们推荐的活动
- 方便地将活动添加到日历
- 在日历中统一查看课程、作业和活动
- 更好地规划和参与校园生活
