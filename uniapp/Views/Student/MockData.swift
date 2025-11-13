//
//  MockData.swift
//  uniapp
//
//  UCL Health Data Science MSc 真实课程数据
//

import Foundation

struct MockData {
    
    // MARK: - UCL Health Data Science MSc 课程表
    static let timetableEvents: [TimetableEvent] = [
        // === TERM 1 (Autumn) 核心课程 ===
        
        // 周一
        TimetableEvent(
            id: "hds-stats-mon",
            title: "Statistical Methods in Health Data Science",
            titleZH: "健康数据科学统计方法",
            courseCode: "HDAT0001",
            type: "Lecture",
            typeZH: "讲座",
            location: "1-19 Torrington Place, Room 115",
            locationZH: "托灵顿广场 1-19 号，115 室",
            startTime: createDate(weekday: 2, hour: 10, minute: 0),
            endTime: createDate(weekday: 2, hour: 12, minute: 0),
            instructor: "Prof. Andrew Copas",
            instructorZH: "安德鲁·科帕斯 教授",
            color: "6366F1"
        ),
        TimetableEvent(
            id: "python-mon",
            title: "Python Programming Workshop",
            titleZH: "Python 编程工作坊",
            courseCode: "HDAT0002",
            type: "Practical",
            typeZH: "实践课",
            location: "UCL Institute of Health Informatics, 222 Euston Road",
            locationZH: "UCL 健康信息学研究所，尤斯顿路 222 号",
            startTime: createDate(weekday: 2, hour: 14, minute: 0),
            endTime: createDate(weekday: 2, hour: 17, minute: 0),
            instructor: "Dr. James Denaxas",
            instructorZH: "詹姆斯·德纳克萨斯 博士",
            color: "10B981"
        ),
        
        // 周二
        TimetableEvent(
            id: "epi-tue",
            title: "Epidemiology for Health Data Science",
            titleZH: "健康数据科学流行病学",
            courseCode: "HDAT0003",
            type: "Lecture",
            typeZH: "讲座",
            location: "Cruciform Building, Gower Street, Lecture Theatre B",
            locationZH: "十字形大楼，高尔街，B 演讲厅",
            startTime: createDate(weekday: 3, hour: 9, minute: 0),
            endTime: createDate(weekday: 3, hour: 11, minute: 0),
            instructor: "Prof. Liam Smeeth",
            instructorZH: "利亚姆·斯米思 教授",
            color: "8B5CF6"
        ),
        TimetableEvent(
            id: "ml-tue",
            title: "Machine Learning Foundations",
            titleZH: "机器学习基础",
            courseCode: "HDAT0004",
            type: "Lecture",
            typeZH: "讲座",
            location: "Roberts Engineering Building, Malet Place, G06",
            locationZH: "罗伯茨工程大楼，马利特广场，G06",
            startTime: createDate(weekday: 3, hour: 13, minute: 0),
            endTime: createDate(weekday: 3, hour: 15, minute: 0),
            instructor: "Dr. Karla Diaz-Ordaz",
            instructorZH: "卡拉·迪亚斯-奥尔达斯 博士",
            color: "F59E0B"
        ),
        
        // 周三
        TimetableEvent(
            id: "database-wed",
            title: "Health Databases and Data Management",
            titleZH: "健康数据库与数据管理",
            courseCode: "HDAT0005",
            type: "Lecture",
            typeZH: "讲座",
            location: "Bentham House, Endsleigh Gardens, B04",
            locationZH: "边沁楼，恩德斯利花园，B04",
            startTime: createDate(weekday: 4, hour: 10, minute: 0),
            endTime: createDate(weekday: 4, hour: 12, minute: 0),
            instructor: "Dr. Spiros Denaxas",
            instructorZH: "斯皮罗斯·德纳克萨斯 博士",
            color: "EF4444"
        ),
        TimetableEvent(
            id: "r-wed",
            title: "R for Health Data Analysis",
            titleZH: "R 语言健康数据分析",
            courseCode: "HDAT0006",
            type: "Computer Lab",
            typeZH: "计算机实验室",
            location: "Foster Court, Gower Street, Room 114",
            locationZH: "福斯特庭院，高尔街，114 室",
            startTime: createDate(weekday: 4, hour: 14, minute: 0),
            endTime: createDate(weekday: 4, hour: 16, minute: 0),
            instructor: "Dr. Ruth Keogh",
            instructorZH: "露丝·基奥 博士",
            color: "10B981"
        ),
        
        // 周四
        TimetableEvent(
            id: "clinical-thu",
            title: "Clinical Informatics and EHR Systems",
            titleZH: "临床信息学与电子健康记录系统",
            courseCode: "HDAT0007",
            type: "Lecture",
            typeZH: "讲座",
            location: "Kathleen Lonsdale Building, Gower Street, LG1",
            locationZH: "凯瑟琳·朗斯代尔大楼，高尔街，LG1",
            startTime: createDate(weekday: 5, hour: 11, minute: 0),
            endTime: createDate(weekday: 5, hour: 13, minute: 0),
            instructor: "Prof. Harry Hemingway",
            instructorZH: "哈里·海明威 教授",
            color: "6366F1"
        ),
        TimetableEvent(
            id: "ethics-thu",
            title: "Ethics and Governance in Health Data",
            titleZH: "健康数据伦理与治理",
            courseCode: "HDAT0008",
            type: "Seminar",
            typeZH: "研讨会",
            location: "Bidborough House, 38-50 Bidborough Street, Room 006",
            locationZH: "比德伯勒楼，比德伯勒街 38-50 号，006 室",
            startTime: createDate(weekday: 5, hour: 15, minute: 0),
            endTime: createDate(weekday: 5, hour: 17, minute: 0),
            instructor: "Dr. Catherine Heeney",
            instructorZH: "凯瑟琳·希尼 博士",
            color: "8B5CF6"
        ),
        
        // 周五
        TimetableEvent(
            id: "project-fri",
            title: "Research Project Supervision",
            titleZH: "研究项目指导",
            courseCode: "HDAT0009",
            type: "Supervision",
            typeZH: "指导课",
            location: "222 Euston Road, IHI Meeting Room 3",
            locationZH: "尤斯顿路 222 号，IHI 会议室 3",
            startTime: createDate(weekday: 6, hour: 10, minute: 0),
            endTime: createDate(weekday: 6, hour: 11, minute: 30),
            instructor: "Assigned Supervisor",
            instructorZH: "指定导师",
            color: "F59E0B"
        ),
        TimetableEvent(
            id: "stats-practical-fri",
            title: "Statistical Methods - Practical Session",
            titleZH: "统计方法 - 实践课",
            courseCode: "HDAT0001",
            type: "Practical",
            typeZH: "实践课",
            location: "Torrington Place 1-19, Computer Room 110",
            locationZH: "托灵顿广场 1-19 号，计算机室 110",
            startTime: createDate(weekday: 6, hour: 13, minute: 0),
            endTime: createDate(weekday: 6, hour: 15, minute: 0),
            instructor: "Teaching Assistant",
            instructorZH: "助教",
            color: "6366F1"
        )
    ]
    
    // MARK: - UCL 真实活动数据
    static let activities: [Activity] = [
        // 学术讲座
        Activity(
            id: "ai-healthcare-lecture",
            title: "AI in Healthcare: From Research to Clinical Practice",
            titleZH: "医疗 AI：从研究到临床实践",
            description: "Join us for an insightful lecture by Prof. Alistair Johnson from MIT on implementing AI systems in real-world healthcare settings. Topics include predictive modeling for ICU patients, ethical considerations, and deployment challenges in NHS hospitals.\n\nThis event is part of the UCL AI Centre's Distinguished Lecture Series.",
            descriptionZH: "加入我们，聆听来自 MIT 的 Alistair Johnson 教授关于在真实医疗环境中实施 AI 系统的精彩讲座。主题包括 ICU 患者预测建模、伦理考量以及 NHS 医院部署挑战。\n\n本次活动是 UCL AI 中心杰出讲座系列的一部分。",
            category: "Academic",
            categoryZH: "学术活动",
            location: "Darwin Lecture Theatre, Darwin Building, Gower Street",
            locationZH: "达尔文演讲厅，达尔文大楼，高尔街",
            startDate: createDate(month: 11, day: 18, hour: 18, minute: 0),
            endDate: createDate(month: 11, day: 18, hour: 19, minute: 30),
            organizerName: "UCL AI Centre & Institute of Health Informatics",
            organizerNameZH: "UCL AI 中心与健康信息学研究所",
            maxParticipants: 180,
            currentParticipants: 142,
            imageURL: "ai-healthcare",
            tags: ["AI", "Healthcare", "Research", "Machine Learning"],
            tagsZH: ["AI", "医疗", "研究", "机器学习"],
            color: "6366F1"
        ),
        
        Activity(
            id: "data-science-workshop",
            title: "Hands-on Workshop: Deep Learning for Medical Imaging",
            titleZH: "实践工作坊：医学影像深度学习",
            description: "A practical workshop covering convolutional neural networks for radiology image analysis. Bring your laptop with Python installed.\n\nWe'll work through real chest X-ray datasets and build models for pneumonia detection. Prior experience with PyTorch recommended but not required.\n\nLunch and refreshments provided.",
            descriptionZH: "一个实用的工作坊，涵盖用于放射影像分析的卷积神经网络。请携带已安装 Python 的笔记本电脑。\n\n我们将使用真实的胸部 X 光数据集，构建肺炎检测模型。建议有 PyTorch 经验，但不强制要求。\n\n提供午餐和茶点。",
            category: "Workshop",
            categoryZH: "工作坊",
            location: "IHI Computer Lab, 222 Euston Road, 1st Floor",
            locationZH: "IHI 计算机实验室，尤斯顿路 222 号，1 楼",
            startDate: createDate(month: 11, day: 21, hour: 10, minute: 0),
            endDate: createDate(month: 11, day: 21, hour: 16, minute: 0),
            organizerName: "Health Data Science Society",
            organizerNameZH: "健康数据科学学会",
            maxParticipants: 40,
            currentParticipants: 38,
            imageURL: "ml-workshop",
            tags: ["Deep Learning", "Medical Imaging", "Workshop", "Python"],
            tagsZH: ["深度学习", "医学影像", "工作坊", "Python"],
            color: "10B981"
        ),
        
        // 社交活动
        Activity(
            id: "pub-night-nov",
            title: "IHI MSc Students Pub Night",
            titleZH: "IHI 硕士生酒吧之夜",
            description: "Monthly social gathering for all Institute of Health Informatics MSc students! Meet your coursemates, share experiences, and unwind after a busy week.\n\nFirst drink on us! 🍺\n\nNo need to book - just turn up. We'll have a reserved area upstairs.",
            descriptionZH: "健康信息学研究所所有硕士生的月度社交聚会！与同学见面，分享经验，在忙碌一周后放松一下。\n\n第一杯我们请！🍺\n\n无需预订，直接来即可。我们在楼上预留了区域。",
            category: "Social",
            categoryZH: "社交活动",
            location: "The Jeremy Bentham Pub, 31 University Street",
            locationZH: "杰里米·边沁酒吧，大学街 31 号",
            startDate: createDate(month: 11, day: 22, hour: 19, minute: 0),
            endDate: createDate(month: 11, day: 22, hour: 23, minute: 0),
            organizerName: "IHI Student Society",
            organizerNameZH: "IHI 学生学会",
            maxParticipants: 60,
            currentParticipants: 47,
            imageURL: "pub-night",
            tags: ["Social", "Networking", "Students"],
            tagsZH: ["社交", "社交网络", "学生"],
            color: "EF4444"
        ),
        
        Activity(
            id: "winter-gala",
            title: "UCL Medicine Winter Gala 2024",
            titleZH: "UCL 医学院 2024 冬季晚会",
            description: "Join us for an elegant evening at one of London's most prestigious venues. The gala includes a three-course dinner, live jazz band, silent auction, and dancing.\n\nDress code: Black tie / Evening wear\n\nProceeds support student mental health initiatives and research scholarships.\n\nEarly bird tickets: £45 | Standard: £55",
            descriptionZH: "加入我们在伦敦最负盛名的场地之一度过一个优雅的夜晚。晚会包括三道菜晚餐、现场爵士乐队、无声拍卖和舞蹈。\n\n着装要求：正装/晚礼服\n\n收益支持学生心理健康倡议和研究奖学金。\n\n早鸟票：£45 | 标准票：£55",
            category: "Social",
            categoryZH: "社交活动",
            location: "The Royal College of Physicians, 11 St Andrews Place, Regent's Park",
            locationZH: "皇家内科医师学院，圣安德鲁广场 11 号，摄政公园",
            startDate: createDate(month: 12, day: 7, hour: 19, minute: 0),
            endDate: createDate(month: 12, day: 8, hour: 1, minute: 0),
            organizerName: "UCL Medical School Students' Association",
            organizerNameZH: "UCL 医学院学生协会",
            maxParticipants: 200,
            currentParticipants: 156,
            imageURL: "winter-gala",
            tags: ["Gala", "Formal", "Fundraiser", "Networking"],
            tagsZH: ["晚会", "正式", "筹款", "社交网络"],
            color: "8B5CF6"
        ),
        
        // 职业发展
        Activity(
            id: "nhs-careers",
            title: "NHS Digital & NHSX Careers Information Session",
            titleZH: "NHS Digital 与 NHSX 职业信息会",
            description: "Representatives from NHS Digital, NHSX, and NHS England will present career opportunities for data scientists and health informaticians.\n\nTopics covered:\n• Graduate schemes and entry routes\n• Day-to-day work in NHS digital teams\n• Application tips and interview process\n• Q&A with current data scientists\n\nBring copies of your CV for informal feedback!",
            descriptionZH: "来自 NHS Digital、NHSX 和 NHS England 的代表将介绍数据科学家和健康信息学家的职业机会。\n\n涵盖主题：\n• 毕业生计划和入职途径\n• NHS 数字团队的日常工作\n• 申请技巧和面试流程\n• 与现任数据科学家的问答\n\n请携带简历副本以获得非正式反馈！",
            category: "Career",
            categoryZH: "职业发展",
            location: "Cruciform Building, Lecture Theatre A, Gower Street",
            locationZH: "十字形大楼，A 演讲厅，高尔街",
            startDate: createDate(month: 11, day: 25, hour: 17, minute: 0),
            endDate: createDate(month: 11, day: 25, hour: 19, minute: 0),
            organizerName: "UCL Careers Service & IHI",
            organizerNameZH: "UCL 职业服务与 IHI",
            maxParticipants: 120,
            currentParticipants: 98,
            imageURL: "nhs-careers",
            tags: ["Career", "NHS", "Jobs", "Healthcare IT"],
            tagsZH: ["职业", "NHS", "工作", "医疗 IT"],
            color: "F59E0B"
        ),
        
        Activity(
            id: "pharma-networking",
            title: "Pharma & Biotech Industry Networking Evening",
            titleZH: "制药与生物技术行业社交晚会",
            description: "Network with data scientists from GSK, AstraZeneca, Novo Nordisk, and emerging biotech startups.\n\nSpeed networking format followed by drinks reception. Companies are actively recruiting for summer internships and graduate positions.\n\nSponsored by GSK AI/ML Centre of Excellence.\n\nSmart casual dress code.",
            descriptionZH: "与来自 GSK、阿斯利康、诺和诺德以及新兴生物技术初创公司的数据科学家建立联系。\n\n快速社交形式，随后是酒会。公司正在积极招聘暑期实习和毕业生职位。\n\n由 GSK AI/ML 卓越中心赞助。\n\n商务休闲着装要求。",
            category: "Career",
            categoryZH: "职业发展",
            location: "GSK House, 980 Great West Road, Brentford (Shuttle bus from UCL)",
            locationZH: "GSK 大厦，大西路 980 号，布伦特福德（从 UCL 有班车）",
            startDate: createDate(month: 12, day: 4, hour: 18, minute: 0),
            endDate: createDate(month: 12, day: 4, hour: 21, minute: 0),
            organizerName: "UCL Careers & Industry Partners",
            organizerNameZH: "UCL 职业服务与行业合作伙伴",
            maxParticipants: 80,
            currentParticipants: 73,
            imageURL: "pharma-network",
            tags: ["Networking", "Pharma", "Biotech", "Jobs"],
            tagsZH: ["社交网络", "制药", "生物技术", "工作"],
            color: "6366F1"
        ),
        
        // 学术会议
        Activity(
            id: "student-conference",
            title: "UCL Health Data Science Student Conference 2024",
            titleZH: "UCL 健康数据科学学生会议 2024",
            description: "Annual conference showcasing research by MSc and PhD students. This year's theme: 'Real-World Evidence and Healthcare AI'.\n\nSchedule:\n09:00 - Registration & Coffee\n09:30 - Keynote: Prof. Mihaela van der Schaar (Cambridge)\n10:30 - Student presentations (3 parallel sessions)\n13:00 - Lunch & poster session\n14:30 - Industry panel discussion\n16:00 - Awards ceremony\n\nPresenting students and volunteers get free entry. Others: £10 (includes lunch).",
            descriptionZH: "展示硕士和博士生研究的年度会议。今年主题：'真实世界证据与医疗 AI'。\n\n日程：\n09:00 - 注册与咖啡\n09:30 - 主题演讲：Mihaela van der Schaar 教授（剑桥）\n10:30 - 学生报告（3 个平行分会）\n13:00 - 午餐与海报展示\n14:30 - 行业小组讨论\n16:00 - 颁奖典礼\n\n报告学生和志愿者免费入场。其他：£10（含午餐）。",
            category: "Conference",
            categoryZH: "学术会议",
            location: "Cruciform Building, Multiple Lecture Theatres, Gower Street",
            locationZH: "十字形大楼，多个演讲厅，高尔街",
            startDate: createDate(month: 12, day: 11, hour: 9, minute: 0),
            endDate: createDate(month: 12, day: 11, hour: 17, minute: 0),
            organizerName: "IHI Graduate School",
            organizerNameZH: "IHI 研究生院",
            maxParticipants: 150,
            currentParticipants: 112,
            imageURL: "student-conf",
            tags: ["Conference", "Research", "Presentations", "Academic"],
            tagsZH: ["会议", "研究", "报告", "学术"],
            color: "8B5CF6"
        ),
        
        // 技能培训
        Activity(
            id: "sql-bootcamp",
            title: "SQL for Healthcare Databases Bootcamp",
            titleZH: "医疗数据库 SQL 训练营",
            description: "Intensive 2-day course covering SQL fundamentals to advanced queries using real NHS hospital datasets (anonymized).\n\nDay 1: SELECT, JOIN, aggregations, subqueries\nDay 2: Window functions, CTEs, performance optimization, working with OMOP CDM\n\nNo prior SQL experience required. Laptops provided.\n\nMaterials and certificate included.",
            descriptionZH: "为期 2 天的强化课程，涵盖 SQL 基础到高级查询，使用真实的 NHS 医院数据集（匿名化）。\n\n第 1 天：SELECT、JOIN、聚合、子查询\n第 2 天：窗口函数、CTE、性能优化、使用 OMOP CDM\n\n无需 SQL 经验。提供笔记本电脑。\n\n包含材料和证书。",
            category: "Training",
            categoryZH: "技能培训",
            location: "IHI Training Suite, 222 Euston Road, 2nd Floor",
            locationZH: "IHI 培训室，尤斯顿路 222 号，2 楼",
            startDate: createDate(month: 11, day: 27, hour: 9, minute: 30),
            endDate: createDate(month: 11, day: 28, hour: 17, minute: 0),
            organizerName: "UCL Advanced Research Computing",
            organizerNameZH: "UCL 高级研究计算",
            maxParticipants: 25,
            currentParticipants: 24,
            imageURL: "sql-training",
            tags: ["SQL", "Databases", "Training", "Healthcare Data"],
            tagsZH: ["SQL", "数据库", "培训", "医疗数据"],
            color: "10B981"
        ),
        
        Activity(
            id: "git-github",
            title: "Version Control with Git & GitHub for Researchers",
            titleZH: "研究人员的 Git 与 GitHub 版本控制",
            description: "Learn essential version control skills for collaborative research projects.\n\nTopics:\n• Git basics: commit, push, pull, branch\n• GitHub workflow and collaboration\n• Managing Jupyter notebooks in Git\n• Best practices for research code\n• Creating reproducible analysis pipelines\n\nBring a laptop with Git installed.",
            descriptionZH: "学习协作研究项目的基本版本控制技能。\n\n主题：\n• Git 基础：commit、push、pull、branch\n• GitHub 工作流和协作\n• 在 Git 中管理 Jupyter notebooks\n• 研究代码最佳实践\n• 创建可重现的分析流程\n\n请携带已安装 Git 的笔记本电脑。",
            category: "Training",
            categoryZH: "技能培训",
            location: "Roberts Building, Computer Lab G08, Malet Place",
            locationZH: "罗伯茨大楼，计算机实验室 G08，马利特广场",
            startDate: createDate(month: 12, day: 3, hour: 14, minute: 0),
            endDate: createDate(month: 12, day: 3, hour: 17, minute: 0),
            organizerName: "Research Software Engineering Team",
            organizerNameZH: "研究软件工程团队",
            maxParticipants: 30,
            currentParticipants: 27,
            imageURL: "git-workshop",
            tags: ["Git", "GitHub", "Programming", "Best Practices"],
            tagsZH: ["Git", "GitHub", "编程", "最佳实践"],
            color: "EF4444"
        ),
        
        // 健康活动
        Activity(
            id: "mindfulness-session",
            title: "Mindfulness & Stress Management for MSc Students",
            titleZH: "硕士生正念与压力管理",
            description: "Feeling overwhelmed with coursework and deadlines? Join certified mindfulness instructor Sarah Chen for a relaxing session.\n\nWe'll practice:\n• Breathing exercises\n• Body scan meditation\n• Mindful movement\n• Strategies for exam stress\n\nSuitable for complete beginners. Bring comfortable clothes and water.\n\nYoga mats provided.",
            descriptionZH: "被课程作业和截止日期压得喘不过气？加入认证正念导师 Sarah Chen 的放松课程。\n\n我们将练习：\n• 呼吸练习\n• 身体扫描冥想\n• 正念运动\n• 考试压力应对策略\n\n适合完全初学者。请携带舒适的衣服和水。\n\n提供瑜伽垫。",
            category: "Wellbeing",
            categoryZH: "健康活动",
            location: "UCL Student Centre, Levelling Up Room, Gower Street",
            locationZH: "UCL 学生中心，升级室，高尔街",
            startDate: createDate(month: 11, day: 29, hour: 12, minute: 0),
            endDate: createDate(month: 11, day: 29, hour: 13, minute: 30),
            organizerName: "UCL Student Support & Wellbeing",
            organizerNameZH: "UCL 学生支持与健康",
            maxParticipants: 20,
            currentParticipants: 16,
            imageURL: "mindfulness",
            tags: ["Wellbeing", "Mental Health", "Stress Management"],
            tagsZH: ["健康", "心理健康", "压力管理"],
            color: "10B981"
        ),
        
        // 竞赛
        Activity(
            id: "datathon-2024",
            title: "UCL Health Data Science Datathon 2024",
            titleZH: "UCL 健康数据科学数据马拉松 2024",
            description: "24-hour data science competition! Teams of 3-5 will tackle a real clinical prediction problem using ICU patient data from MIMIC-IV.\n\nPrizes:\n🥇 1st Place: £1,500 + Amazon vouchers\n🥈 2nd Place: £800\n🥉 3rd Place: £400\n🏆 Best Visualization: £200\n\nMentors from DeepMind Health, Babylon, and UCL faculty available throughout.\n\nFree pizza, snacks, and energy drinks! Sleeping bags welcome.\n\nForm teams or join as individual.",
            descriptionZH: "24 小时数据科学竞赛！3-5 人团队将使用来自 MIMIC-IV 的 ICU 患者数据解决真实的临床预测问题。\n\n奖品：\n🥇 第一名：£1,500 + 亚马逊代金券\n🥈 第二名：£800\n🥉 第三名：£400\n🏆 最佳可视化：£200\n\n来自 DeepMind Health、Babylon 和 UCL 教师的导师全程提供支持。\n\n免费披萨、零食和能量饮料！欢迎携带睡袋。\n\n组队或单独参加。",
            category: "Competition",
            categoryZH: "竞赛",
            location: "Malet Place Engineering Building, Floors 6-8",
            locationZH: "马利特广场工程大楼，6-8 层",
            startDate: createDate(month: 12, day: 14, hour: 10, minute: 0),
            endDate: createDate(month: 12, day: 15, hour: 14, minute: 0),
            organizerName: "UCL Health Data Science Society & Google",
            organizerNameZH: "UCL 健康数据科学学会与 Google",
            maxParticipants: 100,
            currentParticipants: 87,
            imageURL: "datathon",
            tags: ["Competition", "Hackathon", "Data Science", "Prize"],
            tagsZH: ["竞赛", "黑客马拉松", "数据科学", "奖品"],
            color: "F59E0B"
        ),
        
        // 参观活动
        Activity(
            id: "deepmind-visit",
            title: "Company Visit: Google DeepMind Health Lab Tour",
            titleZH: "公司参观：Google DeepMind 健康实验室之旅",
            description: "Exclusive tour of DeepMind's health research lab in King's Cross!\n\nYou'll see:\n• Live demos of AI models for medical imaging\n• Research spaces and compute infrastructure  \n• Meet researchers working on protein folding and drug discovery\n• Q&A with product managers and ML engineers\n• Light refreshments\n\nLimited spaces - MSc Health Data Science students only.\n\nSecurity clearance required - bring photo ID.",
            descriptionZH: "独家参观 DeepMind 在国王十字的健康研究实验室！\n\n您将看到：\n• 医学影像 AI 模型的现场演示\n• 研究空间和计算基础设施\n• 与从事蛋白质折叠和药物发现的研究人员会面\n• 与产品经理和 ML 工程师的问答\n• 茶点\n\n名额有限 - 仅限健康数据科学硕士生。\n\n需要安全许可 - 请携带带照片的身份证件。",
            category: "Industry Visit",
            categoryZH: "行业参观",
            location: "Google DeepMind, 6 Pancras Square, King's Cross (Meet at UCL Main Quad)",
            locationZH: "Google DeepMind，潘克拉斯广场 6 号，国王十字（在 UCL 主广场集合）",
            startDate: createDate(month: 12, day: 9, hour: 14, minute: 0),
            endDate: createDate(month: 12, day: 9, hour: 17, minute: 0),
            organizerName: "UCL-DeepMind Partnership Programme",
            organizerNameZH: "UCL-DeepMind 合作计划",
            maxParticipants: 25,
            currentParticipants: 25,
            imageURL: "deepmind-visit",
            tags: ["Company Visit", "AI", "DeepMind", "Industry"],
            tagsZH: ["公司参观", "AI", "DeepMind", "行业"],
            color: "6366F1"
        ),
        
        Activity(
            id: "royal-free-hospital",
            title: "Clinical Visit: Royal Free Hospital Digital Health Unit",
            titleZH: "临床参观：皇家自由医院数字健康部门",
            description: "Shadow clinicians and health informaticians at Royal Free Hospital's award-winning digital health unit.\n\nSee how EHR systems work in practice, observe clinical decision support tools, and learn about implementing AI in hospital workflows.\n\nRequired: DBS check & occupational health clearance (arranged by UCL)\n\nMeet clinical staff working with the Cerner Millennium system and understand real challenges of healthcare IT.\n\nProfessional dress code required.",
            descriptionZH: "在皇家自由医院屡获殊荣的数字健康部门跟随临床医生和健康信息学家。\n\n了解 EHR 系统在实践中的运作，观察临床决策支持工具，并学习如何在医院工作流程中实施 AI。\n\n要求：DBS 检查和职业健康许可（由 UCL 安排）\n\n与使用 Cerner Millennium 系统的临床工作人员会面，了解医疗 IT 的真实挑战。\n\n要求专业着装。",
            category: "Clinical Visit",
            categoryZH: "临床参观",
            location: "Royal Free Hospital, Pond Street, Hampstead (Meet at hospital main entrance)",
            locationZH: "皇家自由医院，池塘街，汉普斯特德（在医院主入口集合）",
            startDate: createDate(month: 11, day: 30, hour: 9, minute: 0),
            endDate: createDate(month: 11, day: 30, hour: 13, minute: 0),
            organizerName: "IHI Clinical Partnerships",
            organizerNameZH: "IHI 临床合作伙伴关系",
            maxParticipants: 15,
            currentParticipants: 14,
            imageURL: "hospital-visit",
            tags: ["Clinical", "Hospital", "EHR", "Healthcare IT"],
            tagsZH: ["临床", "医院", "EHR", "医疗 IT"],
            color: "EF4444"
        )
    ]
    
    // MARK: - 课程模块数据
    static let modules: [Module] = [
        // Term 1 核心模块
        Module(
            name: "Statistical Methods in Health Data Science",
            code: "HDAT0001",
            credits: 15,
            isCompleted: true,
            assessments: [
                Assessment(name: "Mid-term Exam", weight: 30, score: 65.0),
                Assessment(name: "Final Exam", weight: 50, score: 70.0),
                Assessment(name: "Coursework", weight: 20, score: 72.0)
            ]
        ),
        Module(
            name: "Epidemiology for Health Data Science",
            code: "HDAT0003",
            credits: 15,
            isCompleted: true,
            assessments: [
                Assessment(name: "Essay", weight: 40, score: 75.0),
                Assessment(name: "Final Exam", weight: 60, score: 70.0)
            ]
        ),
        Module(
            name: "Health Databases and Data Management",
            code: "HDAT0005",
            credits: 15,
            isCompleted: true,
            assessments: [
                Assessment(name: "SQL Practical", weight: 30, score: 68.0),
                Assessment(name: "Database Project", weight: 40, score: 62.0),
                Assessment(name: "Final Exam", weight: 30, score: 65.0)
            ]
        ),
        Module(
            name: "Clinical Informatics and EHR Systems",
            code: "HDAT0007",
            credits: 15,
            isCompleted: true,
            assessments: [
                Assessment(name: "EHR Analysis Report", weight: 50, score: 72.0),
                Assessment(name: "Presentation", weight: 20, score: 75.0),
                Assessment(name: "Final Exam", weight: 30, score: 68.0)
            ]
        ),
        
        // Term 2 模块（进行中）
        Module(
            name: "Machine Learning for Health Data",
            code: "HDAT0004",
            credits: 15,
            isCompleted: false,
            assessments: [
                Assessment(name: "ML Project", weight: 50, score: nil),
                Assessment(name: "Coding Assignment", weight: 30, score: 78.0),
                Assessment(name: "Final Exam", weight: 20, score: nil)
            ]
        ),
        Module(
            name: "Natural Language Processing in Healthcare",
            code: "HDAT0010",
            credits: 15,
            isCompleted: false,
            assessments: [
                Assessment(name: "NLP Coursework", weight: 60, score: nil),
                Assessment(name: "Final Exam", weight: 40, score: nil)
            ]
        ),
        Module(
            name: "Causal Inference Methods",
            code: "HDAT0011",
            credits: 15,
            isCompleted: false,
            assessments: [
                Assessment(name: "Problem Sets", weight: 30, score: 70.0),
                Assessment(name: "Research Paper", weight: 40, score: nil),
                Assessment(name: "Final Exam", weight: 30, score: nil)
            ]
        ),
        
        // 选修模块
        Module(
            name: "Advanced Topics in Precision Medicine",
            code: "HDAT0012",
            credits: 15,
            isCompleted: false,
            assessments: [
                Assessment(name: "Literature Review", weight: 40, score: nil),
                Assessment(name: "Case Study", weight: 30, score: nil),
                Assessment(name: "Final Presentation", weight: 30, score: nil)
            ]
        )
    ]
    
    // MARK: - 作业数据
    static let assignments: [Assignment] = [
        Assignment(
            title: "Statistical Analysis: UK Biobank Data",
            course: "HDAT0001",
            dueDate: createDate(month: 11, day: 25, hour: 23, minute: 59)
        ),
        Assignment(
            title: "Critical Appraisal of Cohort Study",
            course: "HDAT0003",
            dueDate: createDate(month: 11, day: 29, hour: 17, minute: 0)
        ),
        Assignment(
            title: "SQL Queries on CPRD Database",
            course: "HDAT0005",
            dueDate: createDate(month: 12, day: 6, hour: 23, minute: 59)
        ),
        Assignment(
            title: "EHR System Evaluation Report",
            course: "HDAT0007",
            dueDate: createDate(month: 12, day: 13, hour: 17, minute: 0)
        ),
        Assignment(
            title: "Predictive Modeling: ICU Mortality Risk",
            course: "HDAT0004",
            dueDate: createDate(month: 12, day: 20, hour: 23, minute: 59)
        ),
        Assignment(
            title: "NLP Project: Clinical Notes Analysis",
            course: "HDAT0010",
            dueDate: createDate(month: 12, day: 15, hour: 23, minute: 59)
        ),
        Assignment(
            title: "Causal Inference Problem Set 3",
            course: "HDAT0011",
            dueDate: createDate(month: 11, day: 27, hour: 17, minute: 0)
        )
    ]
    
    // MARK: - 辅助函数
    private static func createDate(month: Int = 11, day: Int = 15, weekday: Int = 2, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        // 当调用者未显式传入 month/day（使用了默认 11/15）且传入了 weekday 时，将时间锚定到“当前周”的对应星期
        if month == 11 && day == 15 { // 认为是课表的周几排课用法
            let anchor = Date()
            if let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: anchor)) {
                let delta = weekday - calendar.component(.weekday, from: startOfWeek)
                let targetDay = calendar.date(byAdding: .day, value: delta, to: startOfWeek) ?? anchor
                return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: targetDay) ?? anchor
            }
        }
        // 否则按提供的具体年月日创建（用于活动/作业固定日期）
        var components = DateComponents()
        components.year = 2024
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone.current
        return calendar.date(from: components) ?? Date()
    }
}
