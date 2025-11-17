#!/usr/bin/env python3
"""
自动为所有 NavigationView 添加 .navigationViewStyle(.stack)
这可以修复 macOS 上的布局问题
"""

import re
import os
from pathlib import Path

def fix_navigation_view_style(file_path):
    """为文件中的 NavigationView 添加 .navigationViewStyle(.stack)"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 检查是否已经有 navigationViewStyle
    if '.navigationViewStyle(' in content:
        print(f"✓ {file_path.name} - Already has navigationViewStyle")
        return False
    
    # 查找 NavigationView 的结束位置
    # 匹配模式: 一个或多个空格 + } + 换行 + 一个或多个空格 + }
    # 这通常是 NavigationView 的结束
    pattern = r'(\n\s+\})\n(\s+\})\n(\s+)(private var |// MARK:|struct )'
    
    def replacement(match):
        indent = match.group(2)
        return f'{match.group(1)}\n{indent}\n{indent}.navigationViewStyle(.stack)\n{match.group(2)}\n{match.group(3)}{match.group(4)}'
    
    new_content = re.sub(pattern, replacement, content, count=1)
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"✅ {file_path.name} - Added navigationViewStyle")
        return True
    else:
        print(f"⚠️  {file_path.name} - Could not find pattern to fix")
        return False

def main():
    base_dir = Path('/workspaces/uniapp_v2/uniapp/Views')
    
    # 需要修复的文件列表
    files_to_fix = [
        'Student/StudentCalendarView.swift',
        'Student/StudentAcademicsView.swift',
        'Student/StudentEmailView.swift',
        'Student/StudentHealthView.swift',
        'Student/StudentProfileView.swift',
        'Student/StudentAIAssistantView.swift',
        'Parent/ParentCalendarView.swift',
        'Parent/ParentDashboardView.swift',
        'Parent/ParentHealthView.swift',
        'Parent/ParentEmailView.swift',
        'Parent/ParentTodoView.swift',
        'Parent/ParentAIAssistantView.swift',
        'Shared/UCLActivitiesView.swift',
    ]
    
    fixed_count = 0
    for file_rel_path in files_to_fix:
        file_path = base_dir / file_rel_path
        if file_path.exists():
            if fix_navigation_view_style(file_path):
                fixed_count += 1
        else:
            print(f"❌ {file_rel_path} - File not found")
    
    print(f"\n✨ Fixed {fixed_count} files")

if __name__ == '__main__':
    main()
