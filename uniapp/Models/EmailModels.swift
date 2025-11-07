import Foundation

// MARK: - Email Models

struct EmailPreview: Identifiable {
    let id = UUID()
    let title: String
    let sender: String
    let excerpt: String
    let date: String
    let category: String
    let isRead: Bool
}

struct EmailDetailContent {
    let original: String
    let aiTranslation: String
    let aiSummary: [String]
}

// Mock data - 真实邮件内容
let mockEmails = [
    EmailPreview(
        title: "Urgent: Assignment Submission Deadline Extended",
        sender: "Dr. Sarah Johnson <s.johnson@ucl.ac.uk>",
        excerpt: "Dear Students, Due to technical issues with the submission portal, we have extended the deadline for CHME0007 Assignment 2 to Friday, 10th November at 23:59...",
        date: "Today 10:30",
        category: "Urgent",
        isRead: false
    ),
    EmailPreview(
        title: "Week 7 Lecture Materials Now Available",
        sender: "Prof. Michael Chen <m.chen@ucl.ac.uk>",
        excerpt: "Good morning everyone, The lecture slides and supplementary readings for Week 7 (Data Visualization Techniques) have been uploaded to Moodle. Please review...",
        date: "Today 09:15",
        category: "Academic",
        isRead: true
    ),
    EmailPreview(
        title: "Health Data Science Career Fair - 15th November",
        sender: "UCL Careers Service <careers@ucl.ac.uk>",
        excerpt: "Join us for the annual Health Data Science Career Fair! Meet leading employers from NHS, pharmaceutical companies, and tech startups. Register now...",
        date: "Yesterday",
        category: "Events",
        isRead: false
    ),
    EmailPreview(
        title: "Library Resources: Overdue Items Reminder",
        sender: "UCL Library <library@ucl.ac.uk>",
        excerpt: "You currently have 2 items overdue. Please return 'Statistical Methods in Healthcare' and 'Python for Data Analysis' by 8th November to avoid fines...",
        date: "2 days ago",
        category: "Urgent",
        isRead: false
    ),
    EmailPreview(
        title: "Research Assistant Position - Health Data Lab",
        sender: "Prof. Emily Watson <e.watson@ucl.ac.uk>",
        excerpt: "I am looking for a motivated MSc student to join our research team as a part-time Research Assistant. The project focuses on machine learning applications in...",
        date: "3 days ago",
        category: "Academic",
        isRead: true
    ),
    EmailPreview(
        title: "Wellcome Trust Scholarship - Application Deadline Approaching",
        sender: "UCL Scholarships Office <scholarships@ucl.ac.uk>",
        excerpt: "The deadline for Wellcome Trust Health Data Science Scholarship applications is 20th November. This scholarship covers full tuition fees plus £18,000 stipend...",
        date: "4 days ago",
        category: "Urgent",
        isRead: false
    ),
    EmailPreview(
        title: "Python Workshop: Advanced Data Analysis - Register Now",
        sender: "UCL Digital Skills Team <digitalskills@ucl.ac.uk>",
        excerpt: "We're hosting a hands-on Python workshop covering pandas, scikit-learn, and data visualization. Limited spots available. Wednesday 13th Nov, 14:00-17:00...",
        date: "5 days ago",
        category: "Events",
        isRead: true
    ),
    EmailPreview(
        title: "December Exam Timetable Published",
        sender: "Registry & Student Administration <exams@ucl.ac.uk>",
        excerpt: "Your examination timetable for the December session is now available on Portico. CHME0007: 15 Dec, 14:00; CHME0006: 18 Dec, 09:30. Please check for room allocations...",
        date: "1 week ago",
        category: "Urgent",
        isRead: true
    ),
    EmailPreview(
        title: "Computational Lab Session - Attendance Confirmation Required",
        sender: "Dr. James Liu <j.liu@ucl.ac.uk>",
        excerpt: "Please confirm your attendance for this week's computational lab (Thursday 9th Nov, 10:00-13:00, Computer Lab G03). Bring your laptop and ensure Python 3.10+ is installed...",
        date: "1 week ago",
        category: "Academic",
        isRead: false
    ),
    EmailPreview(
        title: "Student Wellbeing: Free Mental Health Support",
        sender: "UCL Student Support <wellbeing@ucl.ac.uk>",
        excerpt: "November can be stressful with assignments and exams approaching. Remember, UCL offers free counselling and mental health support. Book a confidential session...",
        date: "1 week ago",
        category: "Events",
        isRead: true
    )
]

let mockEmailDetails: [String: EmailDetailContent] = [
    "Dr. Sarah Johnson <s.johnson@ucl.ac.uk>": EmailDetailContent(
        original: """
Subject: Urgent: Assignment Submission Deadline Extended

Dear Students,

I hope this email finds you well. Due to unexpected technical issues with the Moodle submission portal earlier this week, we have decided to extend the deadline for CHME0007 Assignment 2: Statistical Analysis of Health Data.

New Deadline: Friday, 10th November 2024 at 23:59

This extension applies to all students enrolled in the module. Please ensure that you submit your work via the updated submission link, which has been tested and is now functioning properly.

Your assignment should include:
• Part A: Data cleaning and preprocessing (30%)
• Part B: Exploratory data analysis with visualizations (40%)
• Part C: Statistical testing and interpretation (30%)

Please remember to include all Python code files and a PDF report. The file size limit is 50MB.

If you continue to experience any technical difficulties, please contact the IT Service Desk immediately and CC me in the email.

Best regards,
Dr. Sarah Johnson
Module Lead, CHME0007
Department of Health Data Science
University College London
""",
        aiTranslation: """
主题：紧急：作业提交截止日期延期

亲爱的同学们，

由于本周 Moodle 提交系统出现技术问题，我们决定延长 CHME0007 作业2（健康数据统计分析）的截止日期。

新截止日期：2024年11月10日（星期五）晚上23:59

此延期适用于所有选修该课程的同学。请确保通过更新后的提交链接上传作业，该链接已经过测试，现在可以正常使用。

作业要求包括：
• A部分：数据清洗和预处理（30分）
• B部分：探索性数据分析与可视化（40分）
• C部分：统计检验和结果解释（30分）

请记得提交所有 Python 代码文件和 PDF 报告。文件大小限制为 50MB。

如果继续遇到技术问题，请立即联系 IT 服务台，并抄送给我。

祝好，
Sarah Johnson 博士
CHME0007 课程负责人
健康数据科学系
伦敦大学学院
""",
        aiSummary: [
            "⏰ 作业截止日期延期至11月10日23:59",
            "📝 包含三部分：数据清洗(30%)、EDA(40%)、统计检验(30%)",
            "💻 需提交 Python 代码和 PDF 报告，文件不超过50MB",
            "⚠️ 如遇技术问题请联系 IT Service Desk 并抄送导师"
        ]
    ),
    "Prof. Michael Chen <m.chen@ucl.ac.uk>": EmailDetailContent(
        original: """
Subject: Week 7 Lecture Materials Now Available

Good morning everyone,

The lecture slides and supplementary readings for Week 7 (Data Visualization Techniques) have been uploaded to Moodle.

This week's topics include:
- Advanced matplotlib and seaborn techniques
- Interactive visualizations with Plotly
- Dashboard creation using Dash
- Best practices for healthcare data visualization

Required reading: Chapter 9 of "Python Data Science Handbook" by Jake VanderPlas (available online)

Optional reading: "Fundamentals of Data Visualization" by Claus O. Wilke (UCL Library e-book)

Please complete the pre-lecture quiz before our session on Tuesday. This week's lab will focus on creating interactive dashboards, so please ensure you have Plotly and Dash libraries installed.

Next week, we'll have a guest lecture from Dr. Emma Williams from NHS Digital discussing real-world applications of data visualization in healthcare settings.

See you in class!

Prof. Michael Chen
CHME0006 Module Coordinator
""",
        aiTranslation: """
主题：第7周课程材料已上传

大家早上好，

第7周（数据可视化技术）的课件和补充阅读材料已上传至 Moodle。

本周主题包括：
- 高级 matplotlib 和 seaborn 技巧
- 使用 Plotly 创建交互式可视化
- 使用 Dash 创建仪表板
- 医疗健康数据可视化最佳实践

必读材料：Jake VanderPlas 著《Python 数据科学手册》第9章（在线可获取）

选读材料：Claus O. Wilke 著《数据可视化基础》（UCL 图书馆电子书）

请在周二上课前完成课前测验。本周实验课将重点练习创建交互式仪表板，请确保已安装 Plotly 和 Dash 库。

下周，NHS Digital 的 Emma Williams 博士将为我们带来客座讲座，讨论数据可视化在医疗领域的实际应用。

课上见！

陈迈克尔教授
CHME0006 课程协调员
""",
        aiSummary: [
            "📚 第7周课件已上传：数据可视化技术（matplotlib、seaborn、Plotly、Dash）",
            "📖 必读：《Python数据科学手册》第9章；选读：《数据可视化基础》",
            "✅ 周二上课前完成课前测验",
            "💻 实验课前安装 Plotly 和 Dash 库",
            "🎤 下周有 NHS Digital 客座讲座"
        ]
    ),
    "UCL Careers Service <careers@ucl.ac.uk>": EmailDetailContent(
        original: """
Subject: Health Data Science Career Fair - 15th November

Dear Health Data Science Students,

We're excited to announce the annual Health Data Science Career Fair on Wednesday, 15th November from 13:00 to 17:00 at the Wilkins Building, South Cloisters.

Confirmed Exhibitors:
• NHS England - Data Science Team
• AstraZeneca - Clinical Data Analytics
• DeepMind Health
• Babylon Health
• Genomics England
• Public Health England
• UCL Hospitals NHS Foundation Trust
• Faculty AI
• Benevolent AI

Event Schedule:
13:00-14:00 - Networking and employer booths
14:00-15:00 - Panel Discussion: "Breaking into Health Data Science"
15:00-15:30 - Coffee break
15:30-17:00 - 1-on-1 sessions and CV reviews

What to Bring:
- Multiple copies of your CV
- Business cards (if you have them)
- Portfolio of projects (on laptop or tablet)
- Notebook for taking notes

Registration is required. Please sign up via CareerConnect by 12th November.

Professional dress code recommended. This is an excellent opportunity to meet potential employers and learn about graduate schemes, internships, and full-time positions.

We look forward to seeing you there!

Best regards,
UCL Careers Service
Health Data Science Sector Team
""",
        aiTranslation: """
主题：健康数据科学招聘会 - 11月15日

亲爱的健康数据科学专业同学，

我们很高兴地宣布年度健康数据科学招聘会将于11月15日（周三）13:00-17:00在威尔金斯大楼南回廊举行。

确认参展企业：
• NHS England - 数据科学团队
• 阿斯利康 - 临床数据分析
• DeepMind Health
• Babylon Health
• 英国基因组学
• 英格兰公共卫生局
• UCL 医院NHS信托基金会
• Faculty AI
• Benevolent AI

活动安排：
13:00-14:00 - 社交和参观展位
14:00-15:00 - 圆桌讨论："进入健康数据科学领域"
15:00-15:30 - 茶歇
15:30-17:00 - 一对一咨询和简历审查

请携带：
- 多份简历
- 名片（如有）
- 项目作品集（笔记本电脑或平板）
- 笔记本

需要提前注册。请在11月12日前通过 CareerConnect 报名。

建议穿着职业装。这是与潜在雇主见面、了解研究生项目、实习和全职职位的绝佳机会。

期待见到你！

祝好，
UCL 职业服务中心
健康数据科学行业团队
""",
        aiSummary: [
            "📅 招聘会：11月15日13:00-17:00，威尔金斯大楼南回廊",
            "🏢 参展企业包括：NHS、阿斯利康、DeepMind、Babylon Health等9家机构",
            "� 需携带：多份简历、作品集、笔记本",
            "✅ 12号前通过 CareerConnect 注册",
            "👔 建议穿职业装，有圆桌讨论和一对一咨询"
        ]
    ),
    "UCL Library <library@ucl.ac.uk>": EmailDetailContent(
        original: """
Subject: Library Resources: Overdue Items Reminder

Dear Zoya,

This is a friendly reminder that you currently have 2 items overdue from UCL Library.

Overdue Items:
1. "Statistical Methods in Healthcare Research" by Sarah Jones
   - Due date: 3rd November 2024
   - Fine accruing: £1.00 per day
   
2. "Python for Data Analysis: Data Wrangling with pandas" by Wes McKinney
   - Due date: 5th November 2024
   - Fine accruing: £1.00 per day

Current total fines: £5.00

Please return these items to any UCL Library location as soon as possible to avoid additional charges. You can also renew items online via Library Services if no other users have placed a hold.

Return Options:
• Main Library - 24-hour book drop available
• Science Library - Open Monday-Friday 09:00-20:00
• Medical Sciences Library - Open Monday-Friday 09:00-18:00

To pay fines or check your account, log in to Library Services through the UCL student portal.

If you have any questions or believe this notice is in error, please contact us at library.loans@ucl.ac.uk

Kind regards,
UCL Library Services
""",
        aiTranslation: """
主题：图书馆资源：逾期归还提醒

亲爱的 Zoya，

这是一封友好提醒，您目前有2本从UCL图书馆借阅的书籍已逾期。

逾期书籍：
1. "医疗健康研究统计方法" - Sarah Jones 著
   - 应还日期：2024年11月3日
   - 罚金累计：每天£1.00
   
2. "Python数据分析：使用pandas进行数据整理" - Wes McKinney 著
   - 应还日期：2024年11月5日
   - 罚金累计：每天£1.00

当前累计罚金：£5.00

请尽快将这些书籍归还至任何UCL图书馆地点以避免额外费用。如果没有其他用户预约，您也可以通过图书馆服务在线续借。

归还地点：
• 主图书馆 - 24小时还书箱
• 科学图书馆 - 周一至周五 09:00-20:00
• 医学科学图书馆 - 周一至周五 09:00-18:00

如需支付罚金或查看账户，请通过UCL学生门户登录图书馆服务系统。

如有任何疑问或认为此通知有误，请联系 library.loans@ucl.ac.uk

祝好，
UCL 图书馆服务
""",
        aiSummary: [
            "📚 有2本书逾期未还",
            "💰 当前累计罚金：£5.00（每本每天£1.00）",
            "� 逾期书籍：《医疗健康研究统计方法》和《Python数据分析》",
            "⏰ 请尽快归还至主图书馆、科学图书馆或医学图书馆",
            "💡 如无人预约可在线续借"
        ]
    ),
    "Prof. Emily Watson <e.watson@ucl.ac.uk>": EmailDetailContent(
        original: """
Subject: Research Assistant Position - Health Data Lab

Dear MSc Health Data Science Students,

I am looking for a motivated and detail-oriented MSc student to join our research team as a part-time Research Assistant for the spring semester (January-June 2025).

Project: "Machine Learning Applications in Predicting Patient Readmission Rates"

This is a collaborative project with UCL Hospitals NHS Foundation Trust, focusing on developing predictive models to identify patients at high risk of hospital readmission within 30 days of discharge.

Responsibilities:
• Data preprocessing and feature engineering from electronic health records
• Implementing and evaluating machine learning algorithms (Random Forest, XGBoost, Neural Networks)
• Literature review and documentation
• Presenting findings at weekly lab meetings
• Co-authoring research papers

Requirements:
• Strong Python programming skills (pandas, scikit-learn, TensorFlow)
• Understanding of healthcare data and clinical workflows
• Excellent communication skills
• Availability: 10-15 hours per week

Compensation: £14.50 per hour (UCL Research Assistant rate)

This is an excellent opportunity to gain hands-on research experience, work with real-world healthcare data, and potentially contribute to publications. The position may also lead to a PhD opportunity.

If interested, please send your CV, academic transcript, and a brief statement (max 300 words) explaining your interest and relevant experience to e.watson@ucl.ac.uk by 15th November.

Interviews will be conducted on 20-22nd November.

Best regards,
Prof. Emily Watson
Principal Investigator
Health Data Research Lab
UCL Institute of Health Informatics
""",
        aiTranslation: """
主题：研究助理职位 - 健康数据实验室

亲爱的健康数据科学硕士同学们，

我正在寻找一位积极主动、注重细节的硕士生，在春季学期（2025年1-6月）加入我们的研究团队，担任兼职研究助理。

项目："机器学习在预测患者再入院率中的应用"

这是与UCL医院NHS信托基金会的合作项目，重点开发预测模型，识别出院后30天内再入院高风险患者。

工作职责：
• 从电子健康记录中进行数据预处理和特征工程
• 实现和评估机器学习算法（随机森林、XGBoost、神经网络）
• 文献综述和文档编写
• 在每周实验室会议上展示研究发现
• 共同撰写研究论文

职位要求：
• 扎实的 Python 编程技能（pandas、scikit-learn、TensorFlow）
• 了解医疗健康数据和临床工作流程
• 出色的沟通能力
• 每周可工作10-15小时

薪资：每小时£14.50（UCL研究助理标准）

这是一个获得实践研究经验、使用真实医疗数据并可能参与发表论文的绝佳机会。该职位也可能带来博士机会。

如有兴趣，请在11月15日前将您的简历、成绩单和简短陈述（最多300字，说明您的兴趣和相关经验）发送至 e.watson@ucl.ac.uk

面试将在11月20-22日进行。

祝好，
Emily Watson 教授
首席研究员
健康数据研究实验室
UCL 健康信息学研究所
""",
        aiSummary: [
            "💼 招聘兼职研究助理：2025年1-6月，每周10-15小时，£14.50/小时",
            "🔬 项目：使用机器学习预测患者30天再入院风险，与UCL医院合作",
            "📋 要求：精通Python（pandas/scikit-learn/TensorFlow）、了解医疗数据",
            "✅ 11月15日前提交：CV + 成绩单 + 300字陈述",
            "📅 面试时间：11月20-22日",
            "🎯 福利：实践经验、真实数据、可能发表论文、潜在博士机会"
        ]
    )
]
