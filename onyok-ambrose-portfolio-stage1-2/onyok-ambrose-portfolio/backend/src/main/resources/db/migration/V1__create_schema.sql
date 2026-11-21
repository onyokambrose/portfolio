-- =====================================================================
-- V1: core schema for the Onyok Ambrose portfolio (PostgreSQL 14+)
--
-- Conventions
--   * BIGSERIAL primary keys, TIMESTAMPTZ for all instants
--   * Dates are DATE; "currently" items have no end date (enforced by CHECK)
--   * Display ordering is an integer column on every list-type table
--   * Images and PDFs live in media_files (BYTEA) so they survive redeploys
-- =====================================================================

-- ---------------------------------------------------------------------
-- Administrators (no public registration; created by the bootstrap logic)
-- ---------------------------------------------------------------------
CREATE TABLE admin_users (
    id              BIGSERIAL PRIMARY KEY,
    username        VARCHAR(50)  NOT NULL UNIQUE,
    password_hash   VARCHAR(100) NOT NULL,            -- BCrypt, never plain text
    display_name    VARCHAR(120) NOT NULL,
    role            VARCHAR(20)  NOT NULL DEFAULT 'EDITOR'
                    CHECK (role IN ('ADMIN', 'EDITOR')),
    -- ADMIN: full control including appearance and accounts
    -- EDITOR: manages content only
    enabled         BOOLEAN      NOT NULL DEFAULT TRUE,
    failed_logins   INTEGER      NOT NULL DEFAULT 0 CHECK (failed_logins >= 0),
    locked_until    TIMESTAMPTZ,
    last_login_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- Uploaded files (profile photo, project images, certificates, logo...)
-- ---------------------------------------------------------------------
CREATE TABLE media_files (
    id              BIGSERIAL PRIMARY KEY,
    purpose         VARCHAR(30)  NOT NULL
                    CHECK (purpose IN ('PROFILE_PHOTO', 'PROJECT_IMAGE', 'CERTIFICATE',
                                       'ACHIEVEMENT', 'LOGO', 'FAVICON', 'HERO_BACKGROUND')),
    original_name   VARCHAR(255) NOT NULL,
    content_type    VARCHAR(100) NOT NULL
                    CHECK (content_type IN ('image/jpeg', 'image/png', 'image/webp', 'application/pdf')),
    size_bytes      INTEGER      NOT NULL CHECK (size_bytes > 0 AND size_bytes <= 5242880),
    sha256          CHAR(64)     NOT NULL,            -- integrity check and HTTP ETag
    data            BYTEA        NOT NULL,
    uploaded_by     BIGINT REFERENCES admin_users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- Personal profile: exactly one row (id is fixed to 1)
-- ---------------------------------------------------------------------
CREATE TABLE personal_profile (
    id                      SMALLINT     PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    full_name               VARCHAR(120) NOT NULL,
    professional_headline   VARCHAR(200) NOT NULL,
    short_introduction      VARCHAR(400),
    biography               TEXT,
    email                   VARCHAR(255),
    phone                   VARCHAR(40),
    location                VARCHAR(160),
    profile_photo_id        BIGINT REFERENCES media_files(id) ON DELETE SET NULL,
    updated_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- Social links shown on the homepage and contact page
-- ---------------------------------------------------------------------
CREATE TABLE social_links (
    id              BIGSERIAL PRIMARY KEY,
    platform        VARCHAR(40)  NOT NULL,            -- e.g. GitHub, LinkedIn, X
    url             VARCHAR(500) NOT NULL CHECK (url ~* '^https?://'),
    display_order   INTEGER      NOT NULL DEFAULT 0,
    visible         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- Education
-- ---------------------------------------------------------------------
CREATE TABLE education (
    id                  BIGSERIAL PRIMARY KEY,
    institution         VARCHAR(200) NOT NULL,
    qualification       VARCHAR(200) NOT NULL,
    field_of_study      VARCHAR(200),
    location            VARCHAR(160),
    start_date          DATE         NOT NULL,
    end_date            DATE,
    currently_enrolled  BOOLEAN      NOT NULL DEFAULT FALSE,
    grade_or_result     VARCHAR(100),
    description         TEXT,
    display_order       INTEGER      NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_education_dates
        CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_education_enrolment
        CHECK (NOT (currently_enrolled AND end_date IS NOT NULL))
);

-- ---------------------------------------------------------------------
-- Skills, grouped into categories
-- ---------------------------------------------------------------------
CREATE TABLE skill_categories (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     VARCHAR(300),
    display_order   INTEGER      NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE skills (
    id                  BIGSERIAL PRIMARY KEY,
    category_id         BIGINT       NOT NULL REFERENCES skill_categories(id) ON DELETE RESTRICT,
    name                VARCHAR(100) NOT NULL,
    proficiency_level   VARCHAR(20)  NOT NULL DEFAULT 'INTERMEDIATE'
                        CHECK (proficiency_level IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT')),
    display_order       INTEGER      NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_skill_per_category UNIQUE (category_id, name)
);

CREATE INDEX idx_skills_category ON skills(category_id);

-- ---------------------------------------------------------------------
-- Projects, their technologies and images
-- ---------------------------------------------------------------------
CREATE TABLE projects (
    id              BIGSERIAL PRIMARY KEY,
    title           VARCHAR(160) NOT NULL,
    summary         VARCHAR(400) NOT NULL,
    description     TEXT,
    github_url      VARCHAR(500),
    live_url        VARCHAR(500),
    featured        BOOLEAN      NOT NULL DEFAULT FALSE,
    visible         BOOLEAN      NOT NULL DEFAULT TRUE,
    display_order   INTEGER      NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_project_github CHECK (github_url IS NULL OR github_url ~* '^https?://'),
    CONSTRAINT chk_project_live   CHECK (live_url IS NULL OR live_url ~* '^https?://')
);

CREATE INDEX idx_projects_featured ON projects(featured, display_order);

CREATE TABLE project_technologies (
    id              BIGSERIAL PRIMARY KEY,
    project_id      BIGINT      NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name            VARCHAR(60) NOT NULL,
    display_order   INTEGER     NOT NULL DEFAULT 0,
    CONSTRAINT uq_project_technology UNIQUE (project_id, name)
);

CREATE TABLE project_images (
    id              BIGSERIAL PRIMARY KEY,
    project_id      BIGINT      NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    media_id        BIGINT      NOT NULL REFERENCES media_files(id) ON DELETE CASCADE,
    caption         VARCHAR(200),
    is_cover        BOOLEAN     NOT NULL DEFAULT FALSE,
    display_order   INTEGER     NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_project_image_media UNIQUE (project_id, media_id)
);

-- A project can have at most one cover image
CREATE UNIQUE INDEX uq_project_one_cover ON project_images(project_id) WHERE is_cover;

-- ---------------------------------------------------------------------
-- Work experience and its responsibilities
-- ---------------------------------------------------------------------
CREATE TABLE work_experience (
    id                  BIGSERIAL PRIMARY KEY,
    job_title           VARCHAR(160) NOT NULL,
    organisation        VARCHAR(200) NOT NULL,
    location            VARCHAR(160),
    employment_type     VARCHAR(40),                  -- e.g. Internship, Part-time, Volunteer
    start_date          DATE         NOT NULL,
    end_date            DATE,
    currently_working   BOOLEAN      NOT NULL DEFAULT FALSE,
    summary             TEXT,
    display_order       INTEGER      NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_experience_dates
        CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_experience_current
        CHECK (NOT (currently_working AND end_date IS NOT NULL))
);

CREATE TABLE experience_responsibilities (
    id              BIGSERIAL PRIMARY KEY,
    experience_id   BIGINT       NOT NULL REFERENCES work_experience(id) ON DELETE CASCADE,
    description     VARCHAR(500) NOT NULL,
    display_order   INTEGER      NOT NULL DEFAULT 0
);

CREATE INDEX idx_responsibilities_experience ON experience_responsibilities(experience_id);

-- ---------------------------------------------------------------------
-- Certificates
-- ---------------------------------------------------------------------
CREATE TABLE certificates (
    id                      BIGSERIAL PRIMARY KEY,
    title                   VARCHAR(200) NOT NULL,
    issuing_organisation    VARCHAR(200) NOT NULL,
    issued_on               DATE         NOT NULL,
    expires_on              DATE,
    credential_id           VARCHAR(120),
    credential_url          VARCHAR(500) CHECK (credential_url IS NULL OR credential_url ~* '^https?://'),
    file_id                 BIGINT REFERENCES media_files(id) ON DELETE SET NULL,
    display_order           INTEGER      NOT NULL DEFAULT 0,
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_certificate_dates CHECK (expires_on IS NULL OR expires_on >= issued_on)
);

-- ---------------------------------------------------------------------
-- Achievements and awards
-- ---------------------------------------------------------------------
CREATE TABLE achievements (
    id              BIGSERIAL PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    awarding_body   VARCHAR(200),
    achieved_on     DATE,
    description     TEXT,
    image_id        BIGINT REFERENCES media_files(id) ON DELETE SET NULL,
    display_order   INTEGER      NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- Leadership and extracurricular activities
-- ---------------------------------------------------------------------
CREATE TABLE leadership_activities (
    id                  BIGSERIAL PRIMARY KEY,
    role_title          VARCHAR(160) NOT NULL,
    organisation        VARCHAR(200) NOT NULL,
    start_date          DATE,
    end_date            DATE,
    currently_active    BOOLEAN      NOT NULL DEFAULT FALSE,
    description         TEXT,
    display_order       INTEGER      NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_leadership_dates
        CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_leadership_current
        CHECK (NOT (currently_active AND end_date IS NOT NULL))
);

-- ---------------------------------------------------------------------
-- Contact form submissions
-- ---------------------------------------------------------------------
CREATE TABLE contact_messages (
    id              BIGSERIAL PRIMARY KEY,
    sender_name     VARCHAR(120) NOT NULL,
    sender_email    VARCHAR(255) NOT NULL,
    subject         VARCHAR(200) NOT NULL,
    message         TEXT         NOT NULL CHECK (char_length(message) BETWEEN 10 AND 5000),
    status          VARCHAR(20)  NOT NULL DEFAULT 'NEW'
                    CHECK (status IN ('NEW', 'READ', 'ARCHIVED')),
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    read_at         TIMESTAMPTZ,
    archived_at     TIMESTAMPTZ
);

CREATE INDEX idx_contact_status_created ON contact_messages(status, created_at DESC);

-- ---------------------------------------------------------------------
-- Appearance settings: draft (live preview) and published (public site)
-- ---------------------------------------------------------------------
CREATE TABLE appearance_settings (
    id              BIGSERIAL PRIMARY KEY,
    setting_key     VARCHAR(80)  NOT NULL UNIQUE,
    value_type      VARCHAR(20)  NOT NULL
                    CHECK (value_type IN ('COLOR', 'LENGTH', 'NUMBER', 'FONT', 'TOGGLE', 'CHOICE', 'MEDIA')),
    draft_value     VARCHAR(500),
    published_value VARCHAR(500),
    published_at    TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- Homepage section visibility and order (same draft/publish model)
-- ---------------------------------------------------------------------
CREATE TABLE homepage_sections (
    id                      BIGSERIAL PRIMARY KEY,
    section_key             VARCHAR(40)  NOT NULL UNIQUE,
    label                   VARCHAR(120) NOT NULL,
    draft_visible           BOOLEAN      NOT NULL DEFAULT TRUE,
    draft_display_order     INTEGER      NOT NULL,
    published_visible       BOOLEAN      NOT NULL DEFAULT TRUE,
    published_display_order INTEGER      NOT NULL,
    updated_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- Website-wide text settings (site title, meta description, footer)
-- ---------------------------------------------------------------------
CREATE TABLE website_settings (
    id              BIGSERIAL PRIMARY KEY,
    setting_key     VARCHAR(80)  NOT NULL UNIQUE,
    setting_value   TEXT,
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
