
-- Bảng chứa thông tin người dùng hệ thống (sinh viên, giảng viên, admin)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL, -- tên đăng nhập duy nhất
  password_hash VARCHAR(255) NOT NULL, -- mật khẩu đã mã hóa
  email VARCHAR(100) UNIQUE NOT NULL, -- địa chỉ email duy nhất
  account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('student', 'instructor', 'admin')), -- loại tài khoản
  is_active BOOLEAN DEFAULT TRUE, -- trạng thái kích hoạt
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- thời gian tạo
);

-- Bảng định nghĩa các vai trò (role) của hệ thống
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL, -- tên vai trò
  description TEXT -- mô tả vai trò
);

-- Bảng liên kết người dùng với các vai trò
CREATE TABLE user_roles (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id), -- khóa ngoại đến người dùng
  role_id INTEGER REFERENCES roles(id), -- khóa ngoại đến vai trò
  UNIQUE (user_id, role_id) -- mỗi user chỉ có một role cụ thể
);

-- Bảng chứa thông tin các khoa (bộ môn)
CREATE TABLE departments (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL, -- tên khoa
  code VARCHAR(20) UNIQUE NOT NULL -- mã khoa
);

-- Bảng chứa thông tin các chương trình đào tạo
CREATE TABLE programs (
  id SERIAL PRIMARY KEY,
  department_id INTEGER REFERENCES departments(id), -- khóa ngoại đến khoa
  name VARCHAR(100) NOT NULL, -- tên chương trình
  code VARCHAR(20) UNIQUE NOT NULL, -- mã chương trình
  degree_type VARCHAR(50) NOT NULL, -- loại bằng (VD: Cử nhân, Kỹ sư)
  total_credits INTEGER NOT NULL -- tổng số tín chỉ yêu cầu
);

-- Bảng chứa thông tin các lớp sinh viên
CREATE TABLE student_classes (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL, -- tên lớp (VD: KTPM2022)
  program_id INTEGER REFERENCES programs(id), -- chương trình đào tạo
  enrollment_year INTEGER NOT NULL -- năm nhập học
);

-- Bảng thông tin sinh viên
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id), -- liên kết đến người dùng
  student_code VARCHAR(20) UNIQUE NOT NULL, -- mã số sinh viên
  full_name VARCHAR(100) NOT NULL, -- họ tên
  class_id INTEGER REFERENCES student_classes(id), -- lớp sinh viên
  program_id INTEGER REFERENCES programs(id), -- chương trình đào tạo
  enrollment_year INTEGER NOT NULL, -- năm nhập học
  gpa NUMERIC(3,2) -- điểm trung bình tích lũy
);

-- Bảng thông tin giảng viên
CREATE TABLE instructors (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id), -- liên kết đến người dùng
  instructor_code VARCHAR(20) UNIQUE NOT NULL, -- mã giảng viên
  full_name VARCHAR(100) NOT NULL, -- họ tên
  department_id INTEGER REFERENCES departments(id), -- khoa
  specialization TEXT -- chuyên ngành
);

-- Bảng chứa thông tin các môn học
CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  code VARCHAR(20) UNIQUE NOT NULL, -- mã môn học
  name VARCHAR(100) NOT NULL, -- tên môn học
  credits INTEGER NOT NULL, -- số tín chỉ
  department_id INTEGER REFERENCES departments(id) -- khoa quản lý
);

-- Bảng chứa các phiên bản chương trình học
CREATE TABLE program_versions (
  id SERIAL PRIMARY KEY,
  program_id INTEGER REFERENCES programs(id), -- chương trình đào tạo
  start_year INTEGER NOT NULL, -- năm bắt đầu áp dụng
  end_year INTEGER, -- năm kết thúc áp dụng (có thể null nếu đang dùng)
  name VARCHAR(100) NOT NULL -- tên phiên bản chương trình
);

-- Bảng định nghĩa môn học trong từng chương trình học
CREATE TABLE program_courses (
  id SERIAL PRIMARY KEY,
  program_version_id INTEGER REFERENCES program_versions(id), -- phiên bản chương trình
  course_id INTEGER REFERENCES courses(id), -- môn học
  year_number INTEGER NOT NULL, -- năm học (1, 2, 3, 4)
  semester_number INTEGER NOT NULL, -- học kỳ (1, 2)
  is_required BOOLEAN DEFAULT TRUE -- bắt buộc hay tự chọn
);

-- Bảng định nghĩa các học kỳ
CREATE TABLE semesters (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL, -- tên học kỳ (VD: HK1, HK2)
  year VARCHAR(20) NOT NULL, -- năm học (VD: 2023-2024)
  start_date DATE NOT NULL, -- ngày bắt đầu
  end_date DATE NOT NULL, -- ngày kết thúc
  status VARCHAR(20) DEFAULT 'upcoming' -- trạng thái học kỳ (upcoming, ongoing, finished)
);

-- Bảng các môn học được mở trong học kỳ cụ thể
CREATE TABLE course_offerings (
  id SERIAL PRIMARY KEY,
  course_id INTEGER REFERENCES courses(id), -- môn học
  semester_id INTEGER REFERENCES semesters(id), -- học kỳ
  instructor_id INTEGER REFERENCES instructors(id), -- giảng viên phụ trách
  schedule TEXT NOT NULL, -- thời khóa biểu
  max_students INTEGER -- số lượng sinh viên tối đa
);

-- Bảng ghi danh sinh viên vào các môn học đã mở
CREATE TABLE enrollments (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES students(id), -- sinh viên
  course_offering_id INTEGER REFERENCES course_offerings(id), -- môn học mở
  enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- ngày đăng ký
  status VARCHAR(20) DEFAULT 'active' -- trạng thái đăng ký (active, cancelled, etc.)
);

-- Bảng phân công giảng viên dạy các môn học đã mở
CREATE TABLE teaching_assignments (
  id SERIAL PRIMARY KEY,
  instructor_id INTEGER REFERENCES instructors(id), -- giảng viên
  course_offering_id INTEGER REFERENCES course_offerings(id), -- lớp học phần
  is_active BOOLEAN DEFAULT TRUE, -- trạng thái phân công
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- thời gian phân công
);

-- Bảng lưu điểm số sinh viên
CREATE TABLE grades (
  id SERIAL PRIMARY KEY,
  enrollment_id INTEGER REFERENCES enrollments(id), -- liên kết đến đăng ký học phần
  midterm_score NUMERIC(5,2), -- điểm giữa kỳ
  final_score NUMERIC(5,2), -- điểm cuối kỳ
  final_grade VARCHAR(2) -- điểm chữ (VD: A, B, C)
);

-- Bảng lưu các thao tác thay đổi dữ liệu
CREATE TABLE audit_logs (
  id SERIAL PRIMARY KEY,
  table_name VARCHAR(50) NOT NULL, -- tên bảng bị thay đổi
  record_id INTEGER NOT NULL, -- ID bản ghi bị tác động
  action VARCHAR(20) NOT NULL, -- hành động: INSERT, UPDATE, DELETE
  old_values JSONB, -- dữ liệu cũ
  new_values JSONB, -- dữ liệu mới
  performed_by INTEGER REFERENCES users(id), -- người thực hiện
  performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- thời gian thực hiện
);

-- Bảng lưu thông báo hệ thống gửi đến người dùng
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id), -- người nhận thông báo
  title VARCHAR(255) NOT NULL, -- tiêu đề
  message TEXT NOT NULL, -- nội dung
  is_read BOOLEAN DEFAULT FALSE, -- đã đọc hay chưa
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- thời điểm tạo
);
