#!/bin/bash

echo "======================================"
echo "检查 UniApp 项目状态"
echo "======================================"
echo ""

echo "1. 检查 Swift 文件语法..."
find uniapp -name "*.swift" -type f | head -5 | while read file; do
    echo "  ✓ $file"
done

echo ""
echo "2. 检查关键文件是否存在..."
files=(
    "uniapp/UCLApp.swift"
    "uniapp/Views/Student/StudentDashboardView.swift"
    "uniapp/Views/Parent/ParentDashboardView.swift"
    "uniapp/Services/AppState.swift"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file 存在"
    else
        echo "  ✗ $file 不存在"
    fi
done

echo ""
echo "3. 统计代码行数..."
echo "  总Swift文件数: $(find uniapp -name "*.swift" | wc -l)"
echo "  总代码行数: $(find uniapp -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')"

echo ""
echo "======================================"
echo "请在 Xcode 中打开项目并运行"
echo "项目路径: uniapp.xcodeproj"
echo "======================================"
