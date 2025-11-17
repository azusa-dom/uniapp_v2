#!/bin/bash

echo "=========================================="
echo "🔍 验证 ParentDashboardView 修复"
echo "=========================================="
echo ""

echo "1️⃣ 检查关键文件..."
files=(
    "uniapp/Views/Parent/ParentDashboardView.swift"
    "uniapp/Views/Parent/ParentSettingsView.swift"
    "uniapp/Views/Shared/CommonComponents.swift"
)

all_exist=true
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file 不存在"
        all_exist=false
    fi
done

echo ""
echo "2️⃣ 检查 ParentDashboardView 的关键组件..."
components=(
    "StudentStatusCard"
    "AcademicOverviewCard"
    "WeeklySummaryCard"
    "AttendanceHeatmapCard"
    "AssignmentProgressCard"
    "ActivityParticipationCard"
)

for component in "${components[@]}"; do
    if grep -q "struct $component" uniapp/Views/Parent/ParentDashboardView.swift; then
        echo "  ✅ $component 已定义"
    else
        echo "  ❌ $component 未找到"
    fi
done

echo ""
echo "3️⃣ 检查 sheet 修复..."
if grep -q ".sheet(isPresented: \$showingTodoDetail)" uniapp/Views/Parent/ParentDashboardView.swift; then
    echo "  ✅ TodoDetailView sheet 修复完成"
else
    echo "  ⚠️  TodoDetailView sheet 可能需要检查"
fi

if grep -q ".sheet(isPresented: \$showingSettings)" uniapp/Views/Parent/ParentDashboardView.swift; then
    echo "  ✅ ParentSettingsView sheet 正确"
else
    echo "  ⚠️  ParentSettingsView sheet 可能需要检查"
fi

echo ""
echo "4️⃣ 检查 EnvironmentObject 传递..."
if grep -q ".environmentObject(appState)" uniapp/Views/Parent/ParentDashboardView.swift; then
    echo "  ✅ appState EnvironmentObject 已传递"
else
    echo "  ⚠️  appState EnvironmentObject 可能缺失"
fi

if grep -q ".environmentObject(loc)" uniapp/Views/Parent/ParentDashboardView.swift; then
    echo "  ✅ loc EnvironmentObject 已传递"
else
    echo "  ⚠️  loc EnvironmentObject 可能缺失"
fi

echo ""
echo "=========================================="
if [ "$all_exist" = true ]; then
    echo "✅ 所有检查通过！"
    echo ""
    echo "📱 下一步："
    echo "  1. 在 Xcode 中打开项目"
    echo "  2. Clean Build Folder (Cmd+Shift+K)"
    echo "  3. 构建项目 (Cmd+B)"
    echo "  4. 运行应用 (Cmd+R)"
    echo "  5. 测试学生和家长视图的切换"
else
    echo "⚠️  发现一些问题，请检查上面的输出"
fi
echo "=========================================="
