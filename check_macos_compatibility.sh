#!/bin/bash

# macOS 兼容性检查脚本
# 用于检测 Swift 代码中的 iOS 专用 API

echo "🔍 检查 macOS 兼容性问题..."
echo "================================"

found_issues=0

# 检查 navigationBarTitleDisplayMode (需要 #if os(iOS) 包裹)
echo "📱 检查 navigationBarTitleDisplayMode..."
matches=$(grep -r "\.navigationBarTitleDisplayMode(" uniapp/ --include="*.swift" | grep -v "#if os(iOS)" -B1 | grep "navigationBarTitleDisplayMode" || true)
if [ ! -z "$matches" ]; then
    echo "❌ 发现未包裹的 navigationBarTitleDisplayMode:"
    echo "$matches"
    found_issues=$((found_issues + 1))
else
    echo "✅ navigationBarTitleDisplayMode 检查通过"
fi

# 检查 navigationBarHidden (需要 #if os(iOS) 包裹)
echo ""
echo "🙈 检查 navigationBarHidden..."
matches=$(grep -r "\.navigationBarHidden(" uniapp/ --include="*.swift" | grep -v "#if os(iOS)" -B1 | grep "navigationBarHidden" || true)
if [ ! -z "$matches" ]; then
    echo "❌ 发现未包裹的 navigationBarHidden:"
    echo "$matches"
    found_issues=$((found_issues + 1))
else
    echo "✅ navigationBarHidden 检查通过"
fi

# 检查 navigationBarItems (已废弃，应使用 .toolbar)
echo ""
echo "⚠️  检查已废弃的 navigationBarItems..."
matches=$(grep -r "\.navigationBarItems(" uniapp/ --include="*.swift" || true)
if [ ! -z "$matches" ]; then
    echo "❌ 发现已废弃的 navigationBarItems (应使用 .toolbar):"
    echo "$matches"
    found_issues=$((found_issues + 1))
else
    echo "✅ navigationBarItems 检查通过"
fi

# 检查 keyboardType (需要 #if canImport(UIKit) 包裹)
echo ""
echo "⌨️  检查 keyboardType..."
matches=$(grep -r "\.keyboardType(" uniapp/ --include="*.swift" | grep -v "#if canImport(UIKit)" -B1 | grep "keyboardType" || true)
if [ ! -z "$matches" ]; then
    echo "❌ 发现未包裹的 keyboardType:"
    echo "$matches"
    found_issues=$((found_issues + 1))
else
    echo "✅ keyboardType 检查通过"
fi

# 检查 UIColor, UIFont 等 UIKit 特定类型
echo ""
echo "🎨 检查 UIKit 特定类型..."
matches=$(grep -rE "(UIColor\(|UIFont\.|UIImage\(named|\.systemBackground)" uniapp/ --include="*.swift" | grep -v "#if" -B1 | grep -E "(UIColor|UIFont|UIImage|systemBackground)" || true)
if [ ! -z "$matches" ]; then
    echo "⚠️  发现 UIKit 特定类型 (可能需要条件编译):"
    echo "$matches"
    found_issues=$((found_issues + 1))
else
    echo "✅ UIKit 类型检查通过"
fi

# 检查 navigationBarTrailing/Leading (应使用 .automatic)
echo ""
echo "🧭 检查 navigationBar placement..."
matches=$(grep -rE "\.navigationBar(Trailing|Leading)" uniapp/ --include="*.swift" | grep -v "#if os(iOS)" || true)
if [ ! -z "$matches" ]; then
    echo "❌ 发现 navigationBarTrailing/Leading (应使用 .automatic):"
    echo "$matches"
    found_issues=$((found_issues + 1))
else
    echo "✅ toolbar placement 检查通过"
fi

echo ""
echo "================================"
if [ $found_issues -eq 0 ]; then
    echo "✅ 所有检查通过！项目与 macOS 兼容。"
    exit 0
else
    echo "❌ 发现 $found_issues 个潜在的兼容性问题，请修复。"
    exit 1
fi
