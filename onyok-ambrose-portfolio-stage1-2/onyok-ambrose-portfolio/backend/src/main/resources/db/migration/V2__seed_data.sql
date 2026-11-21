-- =====================================================================
-- V2: initial seed data
--
-- Only structural defaults and facts already known are seeded.
-- No dates, achievements, contact details or credentials are invented.
-- The first administrator is created at startup from ADMIN_USERNAME and
-- ADMIN_PASSWORD, so no password appears in this file.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Profile (single row). Edit everything from the admin dashboard.
-- ---------------------------------------------------------------------
INSERT INTO personal_profile (id, full_name, professional_headline, short_introduction, biography, location)
VALUES (
    1,
    'Onyok Ambrose',
    'Information Technology Student at Muni University',
    'Bachelor of Information Technology student at Muni University, Uganda.',
    'Onyok Ambrose is a Bachelor of Information Technology student at Muni University, Uganda.',
    'Uganda'
);

-- ---------------------------------------------------------------------
-- Skill categories (starting structure; add skills from the dashboard)
-- ---------------------------------------------------------------------
INSERT INTO skill_categories (name, description, display_order) VALUES
    ('Programming Languages', 'Languages used to build applications and services', 1),
    ('Web Development',       'Front-end and web technologies',                    2),
    ('Databases',             'Data modelling, querying and administration',        3),
    ('Tools and Platforms',   'Development, version control and deployment tools', 4),
    ('Professional Skills',   'Communication, teamwork and problem solving',        5);

-- ---------------------------------------------------------------------
-- Appearance defaults, using the brand palette.
-- Fonts are placeholders until the Stage 4 design plan is approved.
-- ---------------------------------------------------------------------
INSERT INTO appearance_settings (setting_key, value_type, draft_value, published_value, published_at) VALUES
    -- Colours
    ('color_primary',         'COLOR',  '#E15712', '#E15712', NOW()),
    ('color_secondary',       'COLOR',  '#2FA0E1', '#2FA0E1', NOW()),
    ('color_background',      'COLOR',  '#FFFFFF', '#FFFFFF', NOW()),
    ('color_surface',         'COLOR',  '#F7F9FC', '#F7F9FC', NOW()),
    ('color_text',            'COLOR',  '#172435', '#172435', NOW()),
    ('color_background_dark', 'COLOR',  '#172435', '#172435', NOW()),
    ('color_surface_dark',    'COLOR',  '#22344D', '#22344D', NOW()),
    ('color_text_dark',       'COLOR',  '#F7F9FC', '#F7F9FC', NOW()),
    -- Fonts
    ('font_heading',          'FONT',   'Fraunces',        'Fraunces',        NOW()),
    ('font_body',             'FONT',   'Instrument Sans', 'Instrument Sans', NOW()),
    -- Lengths and numbers
    ('body_font_size',        'LENGTH', '17px', '17px', NOW()),
    ('heading_scale',         'NUMBER', '1.25', '1.25', NOW()),
    ('radius_card',           'LENGTH', '16px', '16px', NOW()),
    ('radius_button',         'LENGTH', '999px', '999px', NOW()),
    -- Choices (allowed values are validated by the application)
    ('button_style',          'CHOICE', 'pill',     'pill',     NOW()),
    ('card_style',            'CHOICE', 'elevated', 'elevated', NOW()),
    ('shadow_style',          'CHOICE', 'soft',     'soft',     NOW()),
    ('hero_layout',           'CHOICE', 'split',    'split',    NOW()),
    ('theme_default',         'CHOICE', 'system',   'system',   NOW()),
    -- Toggles
    ('animations_enabled',    'TOGGLE', 'true', 'true', NOW()),
    -- Media references (NULL means not set; the value is a media_files id)
    ('logo_media_id',         'MEDIA',  NULL, NULL, NULL),
    ('favicon_media_id',      'MEDIA',  NULL, NULL, NULL),
    ('hero_media_id',         'MEDIA',  NULL, NULL, NULL);

-- ---------------------------------------------------------------------
-- Homepage sections, in their default order
-- ---------------------------------------------------------------------
INSERT INTO homepage_sections
    (section_key, label, draft_visible, draft_display_order, published_visible, published_display_order)
VALUES
    ('HERO',              'Hero introduction',       TRUE, 1,  TRUE, 1),
    ('ABOUT',             'About me',                TRUE, 2,  TRUE, 2),
    ('EDUCATION',         'Education',               TRUE, 3,  TRUE, 3),
    ('SKILLS',            'Technical skills',        TRUE, 4,  TRUE, 4),
    ('FEATURED_PROJECTS', 'Featured projects',       TRUE, 5,  TRUE, 5),
    ('EXPERIENCE',        'Work experience',         TRUE, 6,  TRUE, 6),
    ('CERTIFICATIONS',    'Certifications',          TRUE, 7,  TRUE, 7),
    ('ACHIEVEMENTS',      'Achievements',            TRUE, 8,  TRUE, 8),
    ('LEADERSHIP',        'Leadership and activities', TRUE, 9,  TRUE, 9),
    ('CONTACT',           'Contact',                 TRUE, 10, TRUE, 10);

-- ---------------------------------------------------------------------
-- Website text settings
-- ---------------------------------------------------------------------
INSERT INTO website_settings (setting_key, setting_value) VALUES
    ('site_title',            'Onyok Ambrose | Portfolio'),
    ('site_description',      'Curriculum vitae and portfolio of Onyok Ambrose, Information Technology student at Muni University, Uganda.'),
    ('footer_tagline',        'Information Technology student, Muni University'),
    ('footer_copyright_text', 'Onyok Ambrose. All rights reserved.');
