-- 狀態表
create table status(
status_id int primary key identity(1,1),             --狀態id
status_name nvarchar(100),                           --狀態名稱
status_type nvarchar(50)                             --狀態類別
)

-- 職位表
create table position(
position_id int primary key not null identity(1,1),  --職位id
position_name nvarchar(50) not null                  --職位名稱
);

-- 部門表
create table department(
department_id int not null primary key identity(1,1), --部門id
department_name nvarchar(100) not null                --部門名稱
);

-- 員工表
create table employee(
employee_id int not null primary key identity(1001,1), --員工id
employee_name nvarchar(50) not null,                   --員工姓名
password nvarchar(100) not null,                       --密碼
position_id int not null,                              --職位id
department_id int not null,                            --部門id
hire_date date not null,                                --入值日期
status_id int not null,                                --狀態(在職中，離職)
foreign key (position_id) references position(position_id),
foreign key (department_id) references department(department_id),
foreign key (status_id) references status(status_id)
);

-- 員工資料表
create table employee_detail(
employee_id int not null primary key,       --員工id
gender nvarchar(10) not null,                        --姓別
birthday date,                              --生日
identity_card nvarchar(20) not null unique, --身分證
email nvarchar(100) not null unique,        --信箱
phone nvarchar(20) not null unique,                  --電話
employee_photo varbinary(max),                       --照片
address nvarchar(MAX),                           --地址
emergency_contact nvarchar(100),   --緊急聯絡人
emergency_phone nvarchar(20),      --緊急連絡電話
foreign key (employee_id) references employee (employee_id)
);

-- 角色表
create table roles(
role_id int primary key not null identity(1,1),  --角色id
role_name nvarchar(50) not null                  --角色名稱
);

-- 資源表
create table resources(
resources_id int primary key not null identity(1,1),  --資源id
resources_name nvarchar(50) not null                  --資源名稱
);

-- 權限表
create table permissions(                             
permission_id int primary key identity(1,1),          --權限id
role_id int not null,                                 --角色id
resources_id int not null,                            --資源id
action nvarchar(100) not null,                        --能做的動作
foreign key (role_id) references roles (role_id),
foreign key (resources_id) references resources (resources_id)
);

-- 員工角色對照表
create table employee_roles(
employee_id int not null,                             --會員id
role_id int not null,                                 --角色id
primary key (employee_id,role_id),
foreign key (employee_id) references employee (employee_id),
foreign key (role_id) references roles (role_id)
);

-- 工作流程表
create table workprogress(
workprogress_id int primary key identity(1,1),         --工作id
work_name nvarchar(100) not null,                      --工作名
create_date date not null,                             --創建日期
expected_finish_date date not null,                    --預計完成日期
finish_date date,                                      --完成日期
supervisor_id int not null,                            --負責主管
status_id int not null,                                --狀態
progress float not null default 0,                     --進度百分比
foreign key (supervisor_id) references employee (employee_id),
foreign key (status_id) references status(status_id)
)
-- 交辦事項表
create table taskassign(
task_id int primary key identity(1,1),                 --交辦事項id
workprogress_id int not null,                          --工作id
task_name nvarchar(100),                               --交辦名稱
task_content nvarchar(200),                            --交辦內容
assign_id int not null,                                --被交辦對象
reveiew_id int not null,                               --審核對象
create_date date not null,                             --創建日期
expected_finish_date date not null,                    --預計完成日期
finish_date date,                                      --完成日期
status_id int not null,                                --狀態
foreign key (workprogress_id) references workprogress (workprogress_id),
foreign key (assign_id) references employee (employee_id),
foreign key (reveiew_id) references employee (employee_id),
foreign key (status_id) references status(status_id)
)

-- 類型 表（用於儲存各種類型）
CREATE TABLE [types] (
    id INT IDENTITY(1,1) PRIMARY KEY,  
   [type_name] NVARCHAR(100) NOT NULL,                -- 類型名稱
    category NVARCHAR(100) NOT NULL,                 -- 類型分類（例如：leave_type, expense_type, adjustment_type, clock_type, violation_type）
    created_at DATETIME DEFAULT GETDATE()            -- 創建時間，默認為當前時間
);

-- 班別表
create table  [shift_type] (
    [shift_type_id]  INT  PRIMARY KEY  IDENTITY(1,1),  
    department_id  INT  NOT NULL,                   -- 部門 外鍵
    shift_name  NVARCHAR(50)  NOT NULL,             -- 班別名稱
    shift_category NVARCHAR(10)  NOT NULL,         -- 班別類型(早、晚)
    start_time  TIME  NOT NULL,                     -- 開始
    finish_time  TIME  NOT NULL,                    -- 結束
    estimated_hours  DECIMAL(3,2)  NOT NULL,         -- 預計工時
	foreign key (department_id) references department(department_id)
);



-- 出勤紀錄主表
CREATE TABLE attendance (
    id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,                        -- 員工 ID
    shift_type_id INT NOT NULL,                      -- 對應的班表 ID
    total_hours DECIMAL(3,2) DEFAULT 0,                     -- 當天總工時
    regular_hours DECIMAL(3,2) DEFAULT 8,                   -- 正常工時
    overtime_hours DECIMAL(3,2) DEFAULT 0,                  -- 加班工時
    field_work_hours DECIMAL(3,2) DEFAULT 0,                -- 外勤工時
    has_violation BIT DEFAULT 0,                     -- 是否有考勤異常
    status_id INT NOT NULL,                          -- 出勤狀態 (正常/休假/公出等)
    created_at DATETIME DEFAULT GETDATE(),           -- 創建時間，默認為當前時間
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),  
    FOREIGN KEY (shift_type_id) REFERENCES shift_type(shift_type_id), 
    FOREIGN KEY (status_id) REFERENCES status(status_id) 
);

-- 出勤紀錄日誌子表
CREATE TABLE attendance_logs (
    id INT IDENTITY(1,1) PRIMARY KEY,
    parent_attendance_id INT NOT NULL,               -- 關聯考勤 ID
    employee_id INT NOT NULL,                        -- 員工 ID
    clock_time DATETIME NOT NULL,                    -- 打卡時間
    clock_type_id INT NOT NULL,                      -- 打卡類型 (上班/下班等，參考 types 表)
    created_at DATETIME DEFAULT GETDATE(),           -- 創建時間，默認為當前時間
    FOREIGN KEY (parent_attendance_id) REFERENCES attendance(id),  
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),  
    FOREIGN KEY (clock_type_id) REFERENCES types(id)  
);

-- 考勤異常記錄表
CREATE TABLE attendance_violations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,                        -- 員工 ID
    attendance_id INT NOT NULL,                      -- 關聯的考勤 ID
    violation_type_id INT NOT NULL,                  -- 異常類型 (遲到/早退/曠工等)
    violation_minutes INT NOT NULL default 0,                  -- 違規分鐘數
    created_at DATETIME DEFAULT GETDATE(),           -- 創建時間，默認為當前時間
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id), 
    FOREIGN KEY (attendance_id) REFERENCES attendance(id), 
    FOREIGN KEY (violation_type_id) REFERENCES types(id) 
);

-- 請假申請表
CREATE TABLE leave_requests (
    id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,                        -- 員工 ID
    leave_type_id INT NOT NULL,                      -- 參考 types 表
    start_datetime DATETIME NOT NULL,                    -- 請假開始時間
    end_datetime DATETIME NOT NULL,     
	leave_hours INT NOT NULL default 0,
    reason NVARCHAR(MAX),                            -- 請假原因
    status_id INT NOT NULL,                         -- 請假狀態 (預設為 Pending)
    submitted_at DATETIME DEFAULT GETDATE(),         -- 提交時間，默認為當前時間
    attachments NVARCHAR(MAX) NULL,                  -- 附件資訊
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),  
    FOREIGN KEY (leave_type_id) REFERENCES types(id),  
    FOREIGN KEY (status_id) REFERENCES status(status_id)  
);

-- 補卡申請表
CREATE TABLE missing_punch_requests (
    id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,                        -- 員工 ID
    missing_date DATETIME NOT NULL,                  -- 補卡日期
    clock_type_id INT NOT NULL,						 -- 參考 types 表（例如：上班、下班）
    reason NVARCHAR(MAX),							 -- 補卡原因
    status_id INT NOT NULL,					     -- 補卡狀態 (預設為 Pending)
    submitted_at DATETIME DEFAULT GETDATE(),		 -- 提交時間，默認為當前時間
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),  
    FOREIGN KEY (clock_type_id) REFERENCES types(id),  
    FOREIGN KEY (status_id) REFERENCES status(status_id)  
);

-- 費用申請表
CREATE TABLE expense_requests (
    id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,						 -- 員工 ID
    expense_type_id INT NOT NULL,					 -- 參考 types 表
    amount DECIMAL(10,2) NOT NULL,					 -- 費用金額
    description NVARCHAR(MAX),						 -- 描述
    status_id INT NOT NULL,						 -- 費用申請狀態 (預設為 Pending)
    submitted_at DATETIME DEFAULT GETDATE(),	     -- 提交時間，默認為當前時間
    attachments NVARCHAR(MAX) NULL,				     -- 附件資訊
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),  
    FOREIGN KEY (expense_type_id) REFERENCES types(id),  
    FOREIGN KEY (status_id) REFERENCES status(status_id)  
);

-- 加班減班申請表
CREATE TABLE work_adjustment_requests (
    id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,					     -- 員工 ID
    adjustment_type_id INT NOT NULL,				 -- 參考 types 表
    hours DECIMAL(3,2) NOT NULL,					 -- 調整工時
    reason NVARCHAR(MAX),							 -- 調整原因
    status_id INT NOT NULL,						 -- 加班減班狀態 (預設為 Pending)
    submitted_at DATETIME DEFAULT GETDATE(),		 -- 提交時間，默認為當前時間
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),  
    FOREIGN KEY (adjustment_type_id) REFERENCES types(id),  
    FOREIGN KEY (status_id) REFERENCES status(status_id)  
);

-- 簽核流程定義表
CREATE TABLE approval_flows (
    id INT IDENTITY(1,1) PRIMARY KEY,
    flow_name NVARCHAR(100) NOT NULL,				 -- 流程名稱
    request_type_id INT NOT NULL,					 -- 參考 types 表
    step_order INT NOT NULL,						 -- 簽核步驟順序
    approver_position_id INT NOT NULL,			     -- 簽核職位
    next_step_id INT NULL,                            -- NULL 表示無下一步
    created_at DATETIME DEFAULT GETDATE(),		     -- 創建時間，默認為當前時間
    FOREIGN KEY (request_type_id) REFERENCES types(id),
	FOREIGN KEY (next_step_id) REFERENCES approval_flows(id),
	FOREIGN KEY (approver_position_id) REFERENCES position(position_id)
);

-- 簽核步驟狀態表
CREATE TABLE approval_steps (
    id INT IDENTITY(1,1) PRIMARY KEY,
    flow_id INT NOT NULL,						     -- 參考 approval_flows 表
    request_id INT NOT NULL,						 -- 關聯至申請表
    current_step INT NOT NULL,						 -- 當前步驟序號
    approver_user_id INT NOT NULL,					 -- 簽核人 (動態分配)
    status_id INT NOT NULL,							 -- 參考 statuses 表
    comment NVARCHAR(MAX) NULL,						 -- 簽核人填寫的意見
    updated_at DATETIME DEFAULT GETDATE(),			 -- 更新時間，默認為當前時間
    FOREIGN KEY (flow_id) REFERENCES approval_flows(id), 
	FOREIGN KEY (approver_user_id) REFERENCES employee(employee_id), 
    FOREIGN KEY (status_id) REFERENCES status(status_id)  
);
--員工自訂簽核流程表
CREATE TABLE employee_approval_flows (
    id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,   -- 指定的員工
    type_id INT NOT NULL,              -- 申請表單的類型
    flow_id INT NOT NULL,       -- 參考 approval_flows 表
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    FOREIGN KEY (type_id) REFERENCES types(id),
    FOREIGN KEY (flow_id) REFERENCES approval_flows(id)
);

-- 外勤紀錄表
CREATE TABLE field_work_records (
    id INT PRIMARY KEY IDENTITY(1,1),   
    employee_id INT NOT NULL,						 -- 參考員工表
    field_work_date DATE NOT NULL,					 -- 外勤日期
    total_hours DECIMAL(3,2) NOT NULL,				 -- 總外勤工時
    location NVARCHAR(255) NOT NULL,				 -- 外勤地點
    purpose NVARCHAR(255) NOT NULL,				     -- 外勤目的
    created_at DATETIME DEFAULT GETDATE(),			 -- 創建時間，默認為當前時間
    status_id INT NOT NULL,              
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    FOREIGN KEY (status_id) REFERENCES status(status_id)
);

-- 會議室資訊表
create table room (
    id int identity(1,1) primary key, -- 會議室唯一識別碼
    room_name nvarchar(100) not null, -- 會議室名稱
    capacity int not null, -- 容納人數
    image VARBINARY(MAX) null,
    [location] nvarchar(100) not null, -- 會議室位置
);

--會議管理表
create table meeting (
    id int identity(1,1) primary key, -- 會議id
	

    title nvarchar(100) not null, -- 主題
	notes nvarchar(500), -- 會議描述

	
    start_time datetime not null, -- 開始時間
    end_time datetime not null, -- 結束時間

    employee_id int not null, -- 主辦人，關聯到 employee 表
    room_id int not null, -- 會議室，關聯到 rooms 表
	status_id int not null, -- 狀態，關聯到 Status 表
    

    foreign key (employee_id) references employee(employee_id), -- 主辦人外鍵
    foreign key (room_id) references room(id),  -- 會議室外鍵
	foreign key (status_id) references status(status_id) -- 狀態外鍵
);


-- 會議參與者表
create table attendee (
    id int identity(1,1) primary key, -- 參與者id
    meeting_id int not null, -- 會議 id，關聯到 meeting 表
    employee_id int not null, -- 參與者 id，關聯到 employee 表
    foreign key (meeting_id) references meeting(id) on delete cascade, -- 會議外鍵
    foreign key (employee_id) references employee(employee_id) on delete cascade -- 參與者外鍵
);


-- 會議檔案表
create table files (
    id int identity(1,1) primary key, -- 檔案id
    meeting_id int not null, -- 會議 id，關聯到 meeting 表
    employee_id int not null, -- 上傳者 id，關聯到 employee 表
    files_name nvarchar(255) not null, -- 檔案名稱
    files_path nvarchar(500) not null, -- 檔案存放路徑（伺服器上的位置）
    upload_time datetime default getdate(), -- 上傳時間
    foreign key (meeting_id) references meeting(id) on delete cascade, -- 會議外鍵
    foreign key (employee_id) references employee(employee_id) on delete cascade -- 上傳者外鍵
);


-- 會議室租借表
create table rent (
    id int identity(1,1) primary key, -- 租借id

    employee_id int not null, -- 預訂人，關聯到 employee 表
    room_id int not null, -- 會議室，關聯到 rooms 表
    
	meeting_id int not null, -- 會議，關聯到 meeting 表
	status_id int not null, -- 狀態，關聯到 status 表

	foreign key (employee_id) references employee(employee_id), -- 會議室外鍵
    foreign key (room_id) references room(id),  -- 預訂人外鍵
	foreign key (meeting_id) references meeting(id), -- 會議外鍵
    foreign key (status_id) references status(status_id)  -- 狀態外鍵

);





-- 設備資訊表
create table equipment (
    equipment_id int identity(1,1) primary key, -- 設備id
    equipment_name nvarchar(100) not null, -- 設備名稱
    category nvarchar(50), -- 設備類別，可為 null
    equipment_status_id int not null, -- 狀態，關聯到 status 表
    equipment_employee_id int, -- 設備擁有者，可為 null
    purchase_date date, -- 購買日期
    create_time datetime default getdate(), -- 設備創建時間

    foreign key (equipment_employee_id) references employee(employee_id), -- 擁有者外鍵
    foreign key (equipment_status_id) references status(status_id) -- 狀態外鍵
);

-- 設備報修表
create table repair (
    repair_id int identity(1,1) primary key, -- 報修id
    report_time datetime not null default getdate(), -- 報修時間，預設為當前時間
    repair_description nvarchar(max), -- 報修描述
    repair_equipment_id int not null, -- 設備 關聯到 equipment 表
    repair_employee_id int not null, -- 報修的人 關聯到 employee 表
    repair_status_id int not null, -- 狀態 關聯到 status 表
    create_time datetime default getdate(), -- 創建時間

    foreign key (repair_employee_id) references employee(employee_id), -- 報修人外鍵
    foreign key (repair_equipment_id) references equipment(equipment_id), -- 設備資訊外鍵
    foreign key (repair_status_id) references status(status_id) -- 狀態外鍵
);


-- 個人行事曆表
create table personal_calendar(
id int primary key identity(1,1) not null, 
employee_id int not null  ,                          --員工id
start_date  datetime not null,                            --開始
finish_date datetime not null,                           --結束
content nvarchar(max),                            --內容
foreign key (employee_id) references employee(employee_id)
)                                                    --個人行事曆

-- 部門行事曆表
create table department_calendar(
id int primary key identity(1,1) not null, 
department_id int not null,                          --部門id
created_at  datetime not null,                          --開始
finish_date datetime  not null ,                         --結束
content nvarchar(max),                               --內容
foreign key (department_id) references department(department_id)
)                                                    --部門行事曆

-- 公佈欄表
create table bulletin(
id int primary key identity(1,1) not null, 
title nvarchar(50) not null ,                            --標題
creater nvarchar(50) not null,                        --發布者
content nvarchar(max) ,                                 --內容
status_id int not null,                                     --狀態
created_at datetime not null)                         --建立日期

-- 智庫表
CREATE TABLE guideline (
    guide_id INT IDENTITY(1,1) PRIMARY KEY,  -- 主鍵，自動遞增
    guide_title NVARCHAR(255),               -- 標題
    );

-- 智庫內容表
CREATE TABLE guideline_content (
    guideline_content_id INT IDENTITY(1,1) PRIMARY KEY,
    fk_guide_id INT NOT NULL,   
    content_type VARCHAR(10) CHECK (content_type IN ('TEXT', 'IMAGE', 'LINK')),
    text_content NVARCHAR(MAX) ,  -- 文字內容或超連結
    image_content NVARCHAR(MAX) ,  -- 圖片路徑
    FOREIGN KEY (fk_guide_id) REFERENCES guideline(guide_id)
);

-- 排班表
CREATE TABLE schedule (
    schedule_id INT PRIMARY KEY IDENTITY(1,1),   
    department_id INT NOT NULL,                  -- 部門id(外鍵)
    employee_id INT NOT NULL,                    -- 員工id (外鍵)
    schedule_date DATE NOT NULL,                 -- 日期
    shift_type_id INT NOT NULL,                  -- 排班類型(外鍵)
	foreign key (department_id) references department(department_id),
	foreign key (employee_id) references employee(employee_id),
	FOREIGN KEY (shift_type_id) REFERENCES shift_type(shift_type_id), 
    );


-- 基本薪資表
CREATE TABLE salary_setting (
    salary_id INT PRIMARY KEY IDENTITY(1,1),     
    employee_id INT NOT NULL,                    -- 員工(外鍵)
    monthly_salary INT NULL,                     -- 月薪
    hourly_wage INT NOT NULL,                    -- 時薪
	foreign key (employee_id) references employee(employee_id),
);

-- 薪資內容表
CREATE TABLE salary_detail (
    salary_detail_id INT PRIMARY KEY IDENTITY(1,1),  
    employee_id INT NOT NULL,                         -- 員工id (外鍵)
    monthly_regular_hours decimal(3,2) NOT NULL default 0,      -- 一般工時 (月總工時)
    overtime_hours decimal(3,2) NOT NULL default 0,             -- 加班總時數
    late_hours INT NOT NULL default 0,                 -- 遲到(時數)   幾個30分鐘
    early_leave_hours INT NOT NULL default 0,                   -- 早退(時數)   
    leave_days INT NOT NULL default 0,                          -- 請假
    year_month NVARCHAR(20) NOT NULL,                          -- 月份
    earned_salary INT NOT NULL default 0,                       -- 應得薪資
	foreign key (employee_id) references employee(employee_id),
);
CREATE TABLE salary_bonus (
    salary_bonus_id INT PRIMARY KEY IDENTITY(1,1),
    salary_detail_id INT NOT NULL,  -- 關聯 salary_detail
    bonus_type NVARCHAR(50) NOT NULL,  -- 獎金/津貼類型（例如 '交通補助', '績效獎金'）
    amount INT NOT NULL DEFAULT 0,
    FOREIGN KEY (salary_detail_id) REFERENCES salary_detail(salary_detail_id)
);
-- 考績表
CREATE TABLE performance_review (
    review_id INT PRIMARY KEY IDENTITY(1,1),        
    reviewer_employee_id INT NOT NULL,                -- 審核員工id
    reviewed_employee_id INT NOT NULL,                -- 被審核員工id
    rating NVARCHAR(10) NOT NULL,                     -- 等第
    review_date NVARCHAR(10) NOT NULL,                -- 日期
    create_at DATETIME DEFAULT GETDATE(),             
	foreign key (reviewer_employee_id) references employee(employee_id),
	foreign key (reviewed_employee_id) references employee(employee_id)
);

-- 假數表
CREATE TABLE leave_balance (
    leave_balance_id INT PRIMARY KEY IDENTITY(1,1),  
    employee_id INT NOT NULL,                         -- 員工id
    leave_type_id INT NOT NULL,						  -- 假別
    remaining_quantity INT NOT NULL,                  -- 剩餘數量
	year int not null,
    hire_date DATE NOT NULL,                          -- 入職時間
	FOREIGN KEY (leave_type_id) REFERENCES types(id),
	foreign key (employee_id) references employee(employee_id)
);

-- 已請假數量表
CREATE TABLE leave_request (
    leave_request_id INT PRIMARY KEY IDENTITY(1,1),  
    employee_id INT NOT NULL,                         -- 員工id
    leave_type_id INT NOT NULL,                       -- 假別
    quantity INT NOT NULL,                            -- 數量
    year_month NVARCHAR(20) not null,
	foreign key (employee_id) references employee(employee_id),
	FOREIGN KEY (leave_type_id) REFERENCES types(id),
);

-- 加班時數
CREATE TABLE overtime_status (
    overtime_status_id INT PRIMARY KEY IDENTITY(1,1),  
    employee_id INT NOT NULL,                                    -- 員工id
    overtime_hours decimal(3,2) NOT NULL,                        -- 時數
	year_month NVARCHAR(20) not null,
	foreign key (employee_id) references employee(employee_id)
);

create table notify (
    id int identity(1,1) primary key,  
    receive_employee_id int not null,   -- 接收通知的員工 id (申請人)
    approval_steps_id int not null,        -- 參考 approval_steps 表
    message nvarchar(500) not null,       -- 通知訊息
    create_time datetime default getdate(),-- 通知建立時間
    foreign key (receive_employee_id) references employee(employee_id),
    foreign key (approval_steps_id) references approval_steps(id)
);

ALTER TABLE meeting
ADD created_at DATETIME DEFAULT GETDATE();
