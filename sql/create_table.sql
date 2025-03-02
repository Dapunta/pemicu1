-- school
-- berisi data sekolah yang ada di provinsi Sulawesi Selatan
CREATE TABLE school (
    id_school CHAR(15) PRIMARY KEY, -- Format: SCH000000000000
    name VARCHAR(100) NOT NULL,
    type VARCHAR(5) NOT NULL
);

-- registration_path
-- berisi data jalur pendaftaran yang tersedia
CREATE TABLE registration_path (
    id_registration_path CHAR(15) PRIMARY KEY, -- Format: SMU000ddmmyy000
    name VARCHAR(100) NOT NULL
);

-- school_registration_path
-- table penghubung relasi many-to-many antara table school dan table registration_path
-- berisi data sekolah dan jalur yang dibuka
CREATE TABLE school_registration_path (
    school_id_school CHAR(15),
    registration_path_id_registration_path CHAR(15),
    capacity INT NOT NULL,
    used_capacity INT DEFAULT 0,
    PRIMARY KEY (school_id_school, registration_path_id_registration_path),
    FOREIGN KEY (school_id_school) 
        REFERENCES school(id_school)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (registration_path_id_registration_path) 
        REFERENCES registration_path(id_registration_path)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);