-- Tạo schema nếu chưa có
CREATE SCHEMA
IF NOT EXISTS programs;

-- Bảng Departments (Khoa)
CREATE TABLE programs.table_departments
(
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(100) NOT NULL,
  created_at TIMESTAMP
  WITHOUT TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

  -- Bảng Program Units (Ngành học)
  CREATE TABLE programs.table_programs
  (
    id UUID PRIMARY KEY,
    department_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(100) NOT NULL,
    degree_type VARCHAR(100) NOT NULL,
    created_at TIMESTAMP
    WITHOUT TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,

  CONSTRAINT fk_program_unit_department 
    FOREIGN KEY
    (department_id) REFERENCES program.table_departments
    (id)
);

    -- Bảng Courses (Môn học)
    CREATE TABLE programs.table_courses
    (
      id UUID PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      code VARCHAR(100) NOT NULL,
      created_at TIMESTAMP
      WITHOUT TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

      -- Bảng trung gian ProgramUnit - Courses (many-to-many)
      CREATE TABLE programs.table_program_courses
      (
        course_id UUID NOT NULL,
        program_id UUID NOT NULL,

        PRIMARY KEY (course_id, program_id),

        CONSTRAINT fk_course
    FOREIGN KEY (course_id) REFERENCES programs.table_courses(id)
    ON DELETE CASCADE,

        CONSTRAINT fk_program_unit
    FOREIGN KEY (program_id) REFERENCES programs.table_programs(id)
    ON DELETE CASCADE
      );


      CREATE TABLE programs.table_teaching_assignments
      (
        id UUID PRIMARY KEY,
        subjects UUID
        [] NOT NULL,
    employed_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW
        (),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW
        ()
);


        CREATE TABLE programs.teaching_assignment
        (
          id UUID PRIMARY KEY,
          teacher_id UUID NOT NULL,
          department_id UUID NOT NULL,
          subjects UUID
          [] NOT NULL,
    employed_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
