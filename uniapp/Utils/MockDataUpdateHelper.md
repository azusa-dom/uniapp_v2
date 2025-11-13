# MockData 批量更新指南

由于 MockData 文件包含大量数据，需要为所有 `TimetableEvent` 和 `Activity` 添加中文字段。

## 更新模式

### TimetableEvent 更新模式：
```swift
TimetableEvent(
    id: "...",
    title: "English Title",
    titleZH: "中文标题",  // ✅ 添加
    courseCode: "...",
    type: "Lecture",
    typeZH: "讲座",  // ✅ 添加
    location: "English Location",
    locationZH: "中文地点",  // ✅ 添加
    startTime: ...,
    endTime: ...,
    instructor: "English Name",
    instructorZH: "中文姓名",  // ✅ 添加
    color: "..."
)
```

### Activity 更新模式：
```swift
Activity(
    id: "...",
    title: "English Title",
    titleZH: "中文标题",  // ✅ 添加
    description: "English Description",
    descriptionZH: "中文描述",  // ✅ 添加
    category: "Academic",
    categoryZH: "学术活动",  // ✅ 添加
    location: "English Location",
    locationZH: "中文地点",  // ✅ 添加
    startDate: ...,
    endDate: ...,
    organizerName: "English Name",
    organizerNameZH: "中文名称",  // ✅ 添加
    maxParticipants: ...,
    currentParticipants: ...,
    imageURL: "...",
    tags: ["English", "Tags"],
    tagsZH: ["中文", "标签"],  // ✅ 添加
    color: "..."
)
```

## 类型翻译对照表

### 课程类型 (type):
- "Lecture" → "讲座"
- "Practical" → "实践课"
- "Seminar" → "研讨会"
- "Lab" / "Computer Lab" → "实验室" / "计算机实验室"
- "Supervision" → "指导课"
- "Tutorial" → "辅导课"

### 活动分类 (category):
- "Academic" → "学术活动"
- "Workshop" → "工作坊"
- "Social" → "社交活动"
- "Career" → "职业发展"
- "Training" → "技能培训"
- "Conference" → "学术会议"
- "Wellbeing" → "健康活动"

## 快速更新方法

1. 使用 Xcode 的 Find & Replace (Cmd+Shift+F)
2. 逐个查找每个 `TimetableEvent(` 和 `Activity(`
3. 按照模式添加中文字段
4. 使用翻译对照表填充类型和分类

## 注意事项

- 所有中文字段都是必需的，不能为空
- 如果某个字段没有合适的中文翻译，可以使用拼音或保留英文
- 地点名称可以保留英文，或提供中文翻译
- 人名可以保留英文，或提供中文音译

