//
//  MockData.swift
//  uniapp
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
            nameZH: "健康数据科学统计方法",
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
            nameZH: "健康数据科学流行病学",
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
            nameZH: "健康数据库与数据管理",
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
            nameZH: "临床信息学与电子健康记录系统",
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
            nameZH: "健康数据机器学习",
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
            nameZH: "医疗自然语言处理",
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
            nameZH: "因果推断方法",
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
            nameZH: "精准医学前沿专题",
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
    
    // MARK: - 邮件联系人数据库
    static let emailContacts: [EmailContact] = [
        // UCL 教职员工
        EmailContact(
            id: "prof-copas",
            name: "Prof. Andrew Copas",
            email: "a.copas@ucl.ac.uk",
            avatarURL: nil,
            department: "Institute of Health Informatics",
            title: "Professor of Medical Statistics"
        ),
        EmailContact(
            id: "prof-hemingway",
            name: "Prof. Harry Hemingway",
            email: "h.hemingway@ucl.ac.uk",
            avatarURL: nil,
            department: "Institute of Health Informatics",
            title: "Director, IHI"
        ),
        EmailContact(
            id: "dr-denaxas",
            name: "Dr. Spiros Denaxas",
            email: "s.denaxas@ucl.ac.uk",
            avatarURL: nil,
            department: "Institute of Health Informatics",
            title: "Senior Lecturer in Biomedical Informatics"
        ),
        EmailContact(
            id: "prof-smeeth",
            name: "Prof. Liam Smeeth",
            email: "l.smeeth@lshtm.ac.uk",
            avatarURL: nil,
            department: "LSHTM",
            title: "Professor of Clinical Epidemiology"
        ),
        EmailContact(
            id: "dr-diaz",
            name: "Dr. Karla Diaz-Ordaz",
            email: "k.diaz-ordaz@ucl.ac.uk",
            avatarURL: nil,
            department: "Department of Statistical Science",
            title: "Associate Professor"
        ),
        
        // 行政人员
        EmailContact(
            id: "admin-registry",
            name: "Student Registry",
            email: "registry@ucl.ac.uk",
            avatarURL: nil,
            department: "Student Administration",
            title: nil
        ),
        EmailContact(
            id: "admin-finance",
            name: "Student Finance Office",
            email: "student.finance@ucl.ac.uk",
            avatarURL: nil,
            department: "Finance",
            title: nil
        ),
        EmailContact(
            id: "admin-it",
            name: "ISD Service Desk",
            email: "service-desk@ucl.ac.uk",
            avatarURL: nil,
            department: "Information Services Division",
            title: nil
        ),
        EmailContact(
            id: "careers",
            name: "UCL Careers Service",
            email: "careers@ucl.ac.uk",
            avatarURL: nil,
            department: "Careers & Enterprise",
            title: nil
        ),
        EmailContact(
            id: "library",
            name: "UCL Library Services",
            email: "library@ucl.ac.uk",
            avatarURL: nil,
            department: "Library Services",
            title: nil
        ),
        
        // 外部联系人（公司/机构）
        EmailContact(
            id: "nhs-digital",
            name: "NHS Digital Graduate Team",
            email: "graduatescheme@nhs.net",
            avatarURL: nil,
            department: "NHS Digital",
            title: "Recruitment Team"
        ),
        EmailContact(
            id: "deepmind",
            name: "DeepMind Health Team",
            email: "health-partnerships@deepmind.com",
            avatarURL: nil,
            department: "Google DeepMind",
            title: "Partnership Manager"
        ),
        EmailContact(
            id: "gsk-recruit",
            name: "GSK AI/ML Recruitment",
            email: "ai.recruitment@gsk.com",
            avatarURL: nil,
            department: "GSK",
            title: "Talent Acquisition"
        ),
        
        // 学生组织
        EmailContact(
            id: "hds-society",
            name: "Health Data Science Society",
            email: "ucl.healthdatascience@gmail.com",
            avatarURL: nil,
            department: "Student Society",
            title: nil
        ),
        EmailContact(
            id: "ihi-student",
            name: "IHI Student Representative",
            email: "ihi.students@ucl.ac.uk",
            avatarURL: nil,
            department: "Student Union",
            title: nil
        )
    ]
    
    // MARK: - 完整邮件数据
    static let fullEmails: [Email] = {
        let me = EmailContact(id: "me", name: "You", email: "ucabxyz@ucl.ac.uk", avatarURL: nil, department: nil, title: nil)
        
        return [
            // 1. 紧急：作业截止提醒
            Email(
                id: "email-001",
                sender: emailContacts.first(where: { $0.id == "prof-copas" })!,
                recipients: [me],
                cc: [],
                subject: "URGENT: HDAT0001 Statistical Methods Assignment - Submission Deadline Extension",
                subjectZH: "紧急：HDAT0001 统计方法作业 - 提交截止日期延期",
                body: """
                Dear HDAT0001 Students,
                
                Due to the recent technical issues with Moodle, we are extending the deadline for your Statistical Methods assignment from 25 November to **27 November 2024, 23:59**.
                
                **Key Points:**
                • New deadline: 27 Nov 2024, 23:59
                • Submit via Turnitin on Moodle
                • Maximum word count: 2,500 words (excluding references)
                • Late penalties still apply after the new deadline
                
                The assignment brief requires you to:
                1. Analyze the UK Biobank cardiovascular dataset
                2. Perform logistic regression analysis
                3. Interpret results in clinical context
                4. Discuss limitations and potential biases
                
                **Marking Criteria:**
                • Statistical analysis (40%)
                • Interpretation (30%)
                • Critical evaluation (20%)
                • Presentation (10%)
                
                If you have questions, please attend my office hours on Thursday 14:00-16:00 or email me directly.
                
                Good luck with your submissions!
                
                Best regards,
                Prof. Andrew Copas
                Chair, Statistical Methods in Health Data Science
                Institute of Health Informatics, UCL
                """,
                bodyZH: """
                亲爱的 HDAT0001 学生们，
                
                由于最近 Moodle 的技术问题，我们将统计方法作业的截止日期从 11 月 25 日延长至 **2024 年 11 月 27 日 23:59**。
                
                **要点：**
                • 新截止日期：2024 年 11 月 27 日 23:59
                • 通过 Moodle 上的 Turnitin 提交
                • 最大字数：2,500 字（不包括参考文献）
                • 新截止日期后仍会有迟交罚分
                
                作业简介要求您：
                1. 分析英国生物样本库心血管数据集
                2. 进行逻辑回归分析
                3. 在临床背景下解释结果
                4. 讨论局限性和潜在偏差
                
                **评分标准：**
                • 统计分析（40%）
                • 解释（30%）
                • 批判性评估（20%）
                • 呈现（10%）
                
                如有问题，请在周四 14:00-16:00 参加我的办公时间或直接发邮件给我。
                
                祝提交顺利！
                
                此致
                Andrew Copas 教授
                健康数据科学统计方法主任
                UCL 健康信息学研究所
                """,
                timestamp: createDate(month: 11, day: 20, hour: 10, minute: 15),
                isRead: false,
                isStarred: true,
                hasAttachments: true,
                attachments: [
                    EmailAttachment(id: "att-001", fileName: "Assignment_Brief_Updated.pdf", fileType: "pdf", fileSize: 245000, downloadURL: nil),
                    EmailAttachment(id: "att-002", fileName: "UK_Biobank_Dataset_Codebook.xlsx", fileType: "xlsx", fileSize: 1200000, downloadURL: nil)
                ],
                category: .academic,
                priority: .urgent,
                labels: ["Assignment", "Deadline", "HDAT0001"]
            ),
            
            // 2. 学术：研究项目督导邀请
            Email(
                id: "email-002",
                sender: emailContacts.first(where: { $0.id == "dr-denaxas" })!,
                recipients: [me],
                cc: [],
                subject: "MSc Dissertation Project Opportunity: AI-driven Clinical Decision Support",
                subjectZH: "硕士论文项目机会：AI 驱动的临床决策支持",
                body: """
                Hi,
                
                I hope this email finds you well. I'm reaching out because I have an exciting dissertation project opportunity that aligns with your interests in machine learning and clinical informatics.
                
                **Project Title:** Developing Explainable AI Models for Sepsis Early Warning in ICU
                
                **Overview:**
                This project involves building interpretable ML models using MIMIC-IV data to predict sepsis onset 6-12 hours before clinical diagnosis. You'll work with real ICU time-series data and collaborate with clinicians at UCLH.
                
                **What you'll learn:**
                • Feature engineering from EHR time-series data
                • SHAP/LIME for model interpretability
                • Working with healthcare stakeholders
                • Model validation in clinical contexts
                • Writing for medical journals
                
                **Requirements:**
                • Strong Python skills (PyTorch/scikit-learn)
                • Interest in clinical applications
                • Ability to communicate with non-technical audiences
                
                **Timeline:**
                • Project starts: January 2025
                • Literature review: Jan-Feb
                • Data analysis: Mar-Apr
                • Writing & submission: May-Aug
                
                I have funding for conference attendance (e.g., MLHC 2025) if we get good results.
                
                Interested? Let's schedule a meeting next week to discuss further. Please reply with your availability.
                
                Best,
                Spiros
                
                --
                Dr. Spiros Denaxas
                Senior Lecturer in Biomedical Informatics
                Institute of Health Informatics, UCL
                Office: 222 Euston Road, Room 3.07
                """,
                bodyZH: """
                你好，
                
                希望你一切都好。我联系你是因为有一个令人兴奋的论文项目机会，与你对机器学习和临床信息学的兴趣相符。
                
                **项目标题：** 在 ICU 中开发用于脓毒症早期预警的可解释 AI 模型
                
                **概述：**
                该项目涉及使用 MIMIC-IV 数据构建可解释的 ML 模型，以在临床诊断前 6-12 小时预测脓毒症发作。你将使用真实的 ICU 时间序列数据，并与 UCLH 的临床医生合作。
                
                **你将学到：**
                • 从 EHR 时间序列数据中进行特征工程
                • 使用 SHAP/LIME 进行模型可解释性
                • 与医疗利益相关者合作
                • 在临床背景下进行模型验证
                • 为医学期刊撰写论文
                
                **要求：**
                • 强大的 Python 技能（PyTorch/scikit-learn）
                • 对临床应用感兴趣
                • 能够与非技术受众沟通
                
                **时间表：**
                • 项目开始：2025 年 1 月
                • 文献综述：1-2 月
                • 数据分析：3-4 月
                • 撰写和提交：5-8 月
                
                如果我们取得好成果，我有资金支持参加会议（例如 MLHC 2025）。
                
                感兴趣吗？下周安排一次会面进一步讨论。请回复你的时间安排。
                
                此致
                Spiros
                
                --
                Spiros Denaxas 博士
                生物医学信息学高级讲师
                UCL 健康信息学研究所
                办公室：尤斯顿路 222 号，3.07 室
                """,
                timestamp: createDate(month: 11, day: 18, hour: 14, minute: 32),
                isRead: true,
                isStarred: true,
                hasAttachments: false,
                attachments: [],
                category: .academic,
                priority: .high,
                labels: ["Dissertation", "Research", "Opportunity"]
            ),
            
            // 3. 行政：学费缴纳提醒
            Email(
                id: "email-003",
                sender: emailContacts.first(where: { $0.id == "admin-finance" })!,
                recipients: [me],
                cc: [],
                subject: "Action Required: Term 2 Tuition Fee Payment Due 15 December 2024",
                subjectZH: "需要操作：第 2 学期学费付款截止日期为 2024 年 12 月 15 日",
                body: """
                Dear Student,
                
                This is a reminder that your Term 2 tuition fee instalment is due by **15 December 2024**.
                
                **Payment Details:**
                Amount Due: £6,750.00
                Payment Reference: FEES-2024-TERM2-HDAT-MSC
                
                **How to Pay:**
                1. Log into Portico (https://portico.ucl.ac.uk)
                2. Go to 'My Finances' → 'Make a Payment'
                3. Select 'Tuition Fees Term 2'
                4. Follow payment instructions
                
                **Payment Methods Accepted:**
                • Debit/Credit Card
                • Bank Transfer
                • Student Loan (if applicable)
                
                **Important:**
                Late payments may result in:
                • £50 administrative charge
                • Block on exam registration
                • Library access suspension
                • Transcript withholding
                
                If you're experiencing financial difficulties, please contact Student Funding immediately: student-funding@ucl.ac.uk or call 020 7679 0004.
                
                **Already Paid?**
                Please allow 3-5 working days for payment processing. If paid recently, you can disregard this email.
                
                For queries, contact:
                Student Finance Office
                Email: student.finance@ucl.ac.uk
                Phone: 020 7679 2005
                Opening hours: Mon-Fri 10:00-16:00
                
                Kind regards,
                Student Finance Office
                University College London
                """,
                bodyZH: """
                亲爱的学生，
                
                这是一个提醒，你的第 2 学期学费分期付款截止日期为 **2024 年 12 月 15 日**。
                
                **付款详情：**
                应付金额：£6,750.00
                付款参考：FEES-2024-TERM2-HDAT-MSC
                
                **如何付款：**
                1. 登录 Portico (https://portico.ucl.ac.uk)
                2. 前往"我的财务"→"进行付款"
                3. 选择"第 2 学期学费"
                4. 按照付款说明操作
                
                **接受的付款方式：**
                • 借记卡/信用卡
                • 银行转账
                • 学生贷款（如适用）
                
                **重要：**
                逾期付款可能导致：
                • £50 行政费用
                • 考试注册被阻止
                • 图书馆访问暂停
                • 成绩单扣留
                
                如果你遇到财务困难，请立即联系学生资助：student-funding@ucl.ac.uk 或致电 020 7679 0004。
                
                **已付款？**
                请允许 3-5 个工作日处理付款。如果最近已付款，可以忽略此邮件。
                
                如有疑问，请联系：
                学生财务办公室
                邮箱：student.finance@ucl.ac.uk
                电话：020 7679 2005
                开放时间：周一至周五 10:00-16:00
                
                此致
                学生财务办公室
                伦敦大学学院
                """,
                timestamp: createDate(month: 11, day: 19, hour: 9, minute: 0),
                isRead: true,
                isStarred: false,
                hasAttachments: true,
                attachments: [
                    EmailAttachment(id: "att-003", fileName: "Fee_Statement_Term2.pdf", fileType: "pdf", fileSize: 89000, downloadURL: nil)
                ],
                category: .administrative,
                priority: .high,
                labels: ["Finance", "Fees", "Action Required"]
            ),
            
            // 4. 职业：NHS Digital 招聘
            Email(
                id: "email-004",
                sender: emailContacts.first(where: { $0.id == "nhs-digital" })!,
                recipients: [me],
                cc: [],
                subject: "NHS Digital Graduate Scheme 2025 - Apply Now!",
                subjectZH: "NHS Digital 2025 年毕业生计划 - 立即申请！",
                body: """
                Hello,
                
                Thank you for your interest in the NHS Digital Graduate Scheme at our recent UCL careers fair!
                
                We're excited to invite you to apply for our **Data Science & AI Graduate Programme 2025**.
                
                **Programme Highlights:**
                • 2-year structured programme
                • Starting salary: £32,000 (London weighting included)
                • 4 x 6-month rotations across different teams
                • Mentorship from senior data scientists
                • Professional development budget (£2,000/year)
                • Work on real NHS digital transformation projects
                
                **Rotation Areas:**
                1. Clinical Decision Support Systems
                2. Population Health Analytics
                3. AI/ML Research & Development
                4. Data Engineering & Infrastructure
                
                **What We're Looking For:**
                ✓ MSc in Health Data Science, Computer Science, or related field
                ✓ Programming skills: Python, R, SQL
                ✓ Understanding of healthcare systems
                ✓ Strong communication skills
                ✓ Right to work in UK
                
                **Application Deadline: 15 January 2025**
                
                **Application Process:**
                1. Online application form + CV
                2. Online assessment (numerical & logical reasoning)
                3. Video interview
                4. Assessment centre (full day)
                
                **Apply here:** https://jobs.nhs.digital/graduates2025
                
                **Application Tips:**
                • Highlight relevant coursework and projects
                • Show passion for healthcare innovation
                • Demonstrate teamwork experience
                • Give specific examples of problem-solving
                
                We're also hosting a **virtual Q&A session on 5 December 2024, 18:00-19:00**. Register here: [link]
                
                Questions? Reply to this email or contact our recruitment team:
                📧 graduatescheme@nhs.net
                📞 0113 397 2000
                
                We look forward to receiving your application!
                
                Best regards,
                NHS Digital Graduate Recruitment Team
                
                --
                Follow us: @NHSDigital
                Website: digital.nhs.uk/careers
                """,
                bodyZH: """
                你好，
                
                感谢你在我们最近的 UCL 职业博览会上对 NHS Digital 毕业生计划感兴趣！
                
                我们很高兴邀请你申请我们的 **2025 年数据科学与 AI 毕业生项目**。
                
                **项目亮点：**
                • 2 年结构化项目
                • 起薪：£32,000（包括伦敦生活费）
                • 4 x 6 个月轮岗，跨不同团队
                • 高级数据科学家指导
                • 专业发展预算（每年 £2,000）
                • 参与真实的 NHS 数字化转型项目
                
                **轮岗领域：**
                1. 临床决策支持系统
                2. 人口健康分析
                3. AI/ML 研究与开发
                4. 数据工程与基础设施
                
                **我们在寻找：**
                ✓ 健康数据科学、计算机科学或相关领域的硕士学位
                ✓ 编程技能：Python、R、SQL
                ✓ 了解医疗系统
                ✓ 强大的沟通能力
                ✓ 英国工作权
                
                **申请截止日期：2025 年 1 月 15 日**
                
                **申请流程：**
                1. 在线申请表 + 简历
                2. 在线评估（数字和逻辑推理）
                3. 视频面试
                4. 评估中心（全天）
                
                **在此申请：** https://jobs.nhs.digital/graduates2025
                
                **申请技巧：**
                • 突出相关课程和项目
                • 展示对医疗创新的热情
                • 展示团队合作经验
                • 给出具体的解决问题示例
                
                我们还将在 **2024 年 12 月 5 日 18:00-19:00 举办虚拟问答会**。在此注册：[链接]
                
                有问题？回复此邮件或联系我们的招聘团队：
                📧 graduatescheme@nhs.net
                📞 0113 397 2000
                
                期待收到你的申请！
                
                此致
                NHS Digital 毕业生招聘团队
                
                --
                关注我们：@NHSDigital
                网站：digital.nhs.uk/careers
                """,
                timestamp: createDate(month: 11, day: 17, hour: 11, minute: 45),
                isRead: true,
                isStarred: false,
                hasAttachments: true,
                attachments: [
                    EmailAttachment(id: "att-004", fileName: "Graduate_Scheme_Brochure_2025.pdf", fileType: "pdf", fileSize: 3400000, downloadURL: nil),
                    EmailAttachment(id: "att-005", fileName: "Application_Guide.pdf", fileType: "pdf", fileSize: 567000, downloadURL: nil)
                ],
                category: .career,
                priority: .normal,
                labels: ["Jobs", "Graduate Scheme", "NHS"]
            ),
            
            // 5. 社交：活动邀请
            Email(
                id: "email-005",
                sender: emailContacts.first(where: { $0.id == "hds-society" })!,
                recipients: [me],
                cc: [],
                subject: "🎉 You're Invited: HDS Society Christmas Social - 19 Dec 2024",
                subjectZH: "🎉 邀请你：HDS 学会圣诞社交 - 2024 年 12 月 19 日",
                body: """
                Hey there! 👋
                
                The term is almost over, and it's time to celebrate! 🎄✨
                
                The Health Data Science Society is hosting our **Annual Christmas Social** and you're invited!
                
                **📅 When:** Thursday, 19 December 2024, 19:00 - 23:00
                **📍 Where:** The Bloomsbury Bowling Lanes, Tavistock Hotel, Bedford Way
                **🎫 Cost:** £15 (includes bowling, pizza, and 2 drinks)
                
                **What's Happening:**
                🎳 Bowling competition (prizes for winners!)
                🍕 Unlimited pizza buffet
                🍻 Bar with happy hour drinks
                🎁 Secret Santa gift exchange (£10 limit, optional)
                🎵 DJ & dancing
                
                **How to Register:**
                1. Fill out this form: [Google Form link]
                2. Pay £15 via bank transfer or Venmo
                3. Deadline: 10 December 2024
                
                **Bank Details:**
                Account Name: UCL Health Data Science Society
                Sort Code: 40-47-22
                Account Number: 71234567
                Reference: XMAS-[YourName]
                
                **Secret Santa (Optional):**
                Want to join? Add your name to the Secret Santa list in the form. You'll be randomly assigned a recipient and receive yours via email by 13 December.
                
                **Dress Code:** Festive casual! Christmas jumpers encouraged 🎅
                
                Can't wait to see you there! It's been a tough term, and we all deserve some fun before the break.
                
                Questions? Message us on Instagram @ucl_hds or email ucl.healthdatascience@gmail.com
                
                Cheers! 🥳
                HDS Society Committee
                
                P.S. We'll be taking group photos - tag us with #UCLHDSChristmas!
                """,
                bodyZH: """
                嘿！👋
                
                学期快结束了，是时候庆祝一下了！🎄✨
                
                健康数据科学学会将举办我们的 **年度圣诞社交**，邀请你参加！
                
                **📅 时间：** 2024 年 12 月 19 日（周四），19:00 - 23:00
                **📍 地点：** Bloomsbury Bowling Lanes，Tavistock Hotel，Bedford Way
                **🎫 费用：** £15（包括保龄球、披萨和 2 杯饮料）
                
                **活动内容：**
                🎳 保龄球比赛（获胜者有奖品！）
                🍕 无限披萨自助餐
                🍻 酒吧和欢乐时光饮料
                🎁 神秘圣诞老人礼物交换（£10 限额，可选）
                🎵 DJ 和舞蹈
                
                **如何注册：**
                1. 填写此表格：[Google 表格链接]
                2. 通过银行转账或 Venmo 支付 £15
                3. 截止日期：2024 年 12 月 10 日
                
                **银行详情：**
                账户名：UCL Health Data Science Society
                分类代码：40-47-22
                账号：71234567
                参考：XMAS-[你的名字]
                
                **神秘圣诞老人（可选）：**
                想参加吗？在表格中添加你的名字到神秘圣诞老人列表。你将被随机分配一个接收者，并在 12 月 13 日前通过电子邮件收到你的。
                
                **着装要求：** 节日休闲！鼓励穿圣诞毛衣 🎅
                
                迫不及待想见到你！这是一个艰难的学期，我们都应该在假期前好好玩一玩。
                
                有问题？在 Instagram 上给我们留言 @ucl_hds 或发邮件至 ucl.healthdatascience@gmail.com
                
                干杯！🥳
                HDS 学会委员会
                
                附言：我们会拍集体照 - 用 #UCLHDSChristmas 标记我们！
                """,
                timestamp: createDate(month: 11, day: 16, hour: 16, minute: 20),
                isRead: false,
                isStarred: false,
                hasAttachments: false,
                attachments: [],
                category: .social,
                priority: .normal,
                labels: ["Event", "Social", "Christmas"]
            )
        ]
    }()
    
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
