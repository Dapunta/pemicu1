-- 1. Tabel user
CREATE TABLE user (
    id_user           CHAR(15)      NOT NULL,
    name              VARCHAR(255)  NOT NULL,
    nisn              VARCHAR(10)   NOT NULL,
    email             VARCHAR(255)  NOT NULL,
    phone_number      VARCHAR(15)   NOT NULL,
    password          VARCHAR(255)  NOT NULL,
    address           VARCHAR(255)  NOT NULL,
    registration_time DATE          NOT NULL,
    verified          BOOLEAN       NOT NULL DEFAULT 0,
    PRIMARY KEY (id_user)
) ENGINE=InnoDB;

-- 2. Tabel data_user (atribut selain id_user tidak diberi NOT NULL)
CREATE TABLE data_user (
    user_id_user  CHAR(15) NOT NULL,
    nilai_rapot   BLOB,
    akta_kelahiran BLOB,
    ijazah        BLOB,
    PRIMARY KEY (user_id_user),
    FOREIGN KEY (user_id_user)
        REFERENCES user(id_user)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Tabel school
CREATE TABLE school (
    id_school CHAR(15)      NOT NULL,
    name      VARCHAR(255) NOT NULL,
    type      VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_school)
) ENGINE=InnoDB;

-- 4. Tabel registration_path
CREATE TABLE registration_path (
    id_registration_path CHAR(15)      NOT NULL,
    name                 VARCHAR(255)  NOT NULL,
    PRIMARY KEY (id_registration_path)
) ENGINE=InnoDB;

-- 5. Tabel school_registration_path (junction table many-to-many)
CREATE TABLE school_registration_path (
    school_id_school                        CHAR(15) NOT NULL,
    registration_path_id_registration_path  CHAR(15) NOT NULL,
    capacity                                INT      NOT NULL,
    used_capacity                           INT      NOT NULL DEFAULT 0,
    PRIMARY KEY (school_id_school, registration_path_id_registration_path),
    FOREIGN KEY (school_id_school)
        REFERENCES school(id_school)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (registration_path_id_registration_path)
        REFERENCES registration_path(id_registration_path)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. Tabel registration
CREATE TABLE registration (
    id_registration                                                  CHAR(15) NOT NULL,
    user_id_user                                                     CHAR(15) NOT NULL,
    school_registration_path_school_id_school                        CHAR(15) NOT NULL,
    school_registration_path_registration_path_id_registration_path  CHAR(15) NOT NULL,
    registration_time                                                DATE     NOT NULL,
    priority                                                         INT      NOT NULL,
    PRIMARY KEY (id_registration),
    FOREIGN KEY (user_id_user)
        REFERENCES user(id_user)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (school_registration_path_school_id_school, 
                 school_registration_path_registration_path_id_registration_path)
        REFERENCES school_registration_path(school_id_school, registration_path_id_registration_path)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Tabel selection_result
CREATE TABLE selection_result (
    registration_id_registration CHAR(15) NOT NULL,
    score                        INT      NOT NULL,
    status                       VARCHAR(15) NOT NULL,
    PRIMARY KEY (registration_id_registration),
    FOREIGN KEY (registration_id_registration)
        REFERENCES registration(id_registration)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. Tabel final_result
CREATE TABLE final_result (
    selection_result_registration_id_registration CHAR(15) NOT NULL,
    score                                        INT      NOT NULL,
    status                                       VARCHAR(15) NOT NULL,
    PRIMARY KEY (selection_result_registration_id_registration),
    FOREIGN KEY (selection_result_registration_id_registration)
        REFERENCES selection_result(registration_id_registration)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;