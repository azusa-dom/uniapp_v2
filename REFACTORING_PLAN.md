# UCLApp 文件拆分计划

## 当前状态
- 原文件：`UCLApp.swift` (约 8285 行)
- 已创建目录结构：
  - `Models/` - 数据模型
  - `Services/` - 服务类
  - `Views/Student/` - 学生端视图
  - `Views/Parent/` - 家长端视图
  - `Views/Shared/` - 共享组件

## 已完成的拆分

### ✅ Models/
- `TodoModels.swift` - TodoItem, TodoPriority
- `EmailModels.swift` - EmailPreview, EmailDetailContent, mockEmails
- `AcademicModels.swift` - AcademicCourseModule, Deadline

### ✅ Services/
- `AppState.swift` - AppState, UserRole
- `TodoManager.swift` - TodoManager
- `LocalizationService.swift` - LocalizationService (完整)
- `UCLAPIViewModel.swift` - UCLAPIViewModel

## 待拆分的视图文件

### Views/Student/
需要创建以下文件：
1. `StudentDashboardView.swift` - 学生主页 (约 700 行)
2. `StudentEmailView.swift` - 邮件视图 (约 500 行)
3. `StudentCalendarView.swift` - 日历视图 (约 700 行)
4. `StudentAcademicsView.swift` - 学业视图 (约 700 行)
5. `StudentAIAssistantView.swift` - AI 助手 (约 300 行)
6. `StudentProfileView.swift` - 个人资料 (约 300 行)

### Views/Parent/
需要创建以下文件：
1. `ParentDashboardView.swift` - 家长主页 (约 600 行)
2. `ParentCalendarView.swift` - 家长日历 (约 300 行)
3. `ParentTodoView.swift` - 待办事项 (约 400 行)
4. `ParentAIAssistantView.swift` - AI 助手 (约 300 行)
5. `ParentSettingsView.swift` - 设置 (约 200 行)
6. `ParentAcademicDetailView.swift` - 学业详情 (约 100 行)
7. `AttendanceDetailView.swift` - 出勤详情 (约 100 行)

### Views/Shared/
需要创建以下文件：
1. `LoginView.swift` - 登录视图 (约 150 行)
2. `RootView.swift` - 根视图 (约 50 行)
3. `CommonComponents.swift` - 通用组件 (约 1000 行)
   - DesignSystem
   - 各种 Card 组件
   - 各种 Row 组件

## 拆分步骤建议

### 方案 A：逐步拆分（推荐）
1. 先拆分 Views/Shared 中的通用组件
2. 然后拆分学生端视图
3. 最后拆分家长端视图
4. 每次拆分后测试编译

### 方案 B：快速拆分
使用脚本一次性提取所有视图代码（风险较高，需要仔细测试）

## 注意事项

1. **导入语句**：每个新文件都需要：
   ```swift
   import SwiftUI
   import Foundation
   // 根据需要添加其他导入
   ```

2. **依赖关系**：
   - 所有视图文件都需要访问 Models 和 Services
   - 确保所有文件的导入路径正确

3. **编译顺序**：
   - Models → Services → Views
   - 共享组件需要先拆分

4. **测试**：
   - 每次拆分后都要测试编译
   - 确保没有循环依赖
   - 确保所有 EnvironmentObject 正确传递

## 下一步行动

你可以选择：
1. 继续让我完成所有视图文件的拆分（需要多次迭代）
2. 按照这个计划自己逐步拆分
3. 先拆分最重要的几个视图文件

建议：先拆分 Views/Shared 中的通用组件，因为这些组件被很多视图使用。
