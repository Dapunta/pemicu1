-- hapus data table final_result

DELETE FROM final_result

-- set used_capacity kelas ke 0

UPDATE school_registration_path SET used_capacity = 0;

-- cara menghapus procedure

DROP PROCEDURE IF EXISTS ProcessSelection;

-- buat procedure untuk sorting

DELIMITER //

CREATE PROCEDURE ProcessSelection()
BEGIN
    -- Variabel global untuk flag cursor
    DECLARE done INT DEFAULT FALSE;
    DECLARE curr_priority INT;
    
    -- Variabel untuk data registrasi
    DECLARE reg_id CHAR(15);
    DECLARE user_id CHAR(15);
    DECLARE school_id CHAR(15);
    DECLARE path_id CHAR(15);
    DECLARE reg_score INT;
    
    -- Variabel untuk kapasitas
    DECLARE capacity_val INT;
    DECLARE used_val INT;
    
    -- Cursor untuk mengambil list distinct priority secara ascending (1,2,3,...)
    DECLARE priority_cursor CURSOR FOR 
        SELECT DISTINCT priority 
        FROM registration 
        ORDER BY priority ASC;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Kosongkan tabel final_result sebelum memulai proses
    TRUNCATE TABLE final_result;
    
    OPEN priority_cursor;
    priority_loop: LOOP
        FETCH priority_cursor INTO curr_priority;
        IF done THEN
            LEAVE priority_loop;
        END IF;
        
        /* 
           Karena kita ingin mendeklarasikan cursor registrasi per priority,
           kita gunakan blok nested agar deklarasi bisa diletakkan di awal blok.
         */
        BEGIN
            DECLARE done_reg INT DEFAULT FALSE;
            DECLARE reg_cursor CURSOR FOR 
                SELECT 
                    r.id_registration,
                    r.user_id_user,
                    r.school_registration_path_school_id_school,
                    r.school_registration_path_registration_path_id_registration_path,
                    sr.score
                FROM registration r
                JOIN selection_result sr 
                  ON r.id_registration = sr.registration_id_registration
                WHERE r.priority = curr_priority
                ORDER BY sr.score DESC;
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_reg = TRUE;
            
            OPEN reg_cursor;
            registration_loop: LOOP
                FETCH reg_cursor INTO reg_id, user_id, school_id, path_id, reg_score;
                IF done_reg THEN
                    LEAVE registration_loop;
                END IF;
                
                -- Cek kapasitas pada tabel school_registration_path
                SELECT capacity, used_capacity 
                  INTO capacity_val, used_val
                  FROM school_registration_path 
                  WHERE school_id_school = school_id 
                    AND registration_path_id_registration_path = path_id;
                    
                IF used_val < capacity_val THEN
                    -- Cek apakah user sudah diterima di priority yang lebih rendah (lebih baik)
                    IF NOT EXISTS (
                        SELECT 1 
                        FROM final_result fr
                        JOIN registration r2 
                          ON fr.selection_result_registration_id_registration = r2.id_registration
                        WHERE r2.user_id_user = user_id 
                          AND r2.priority < curr_priority
                          AND fr.status = 'lolos'
                    ) THEN
                        -- Belum diterima di prioritas lebih tinggi, masukkan sebagai 'lolos'
                        INSERT INTO final_result (selection_result_registration_id_registration, score, status)
                        VALUES (reg_id, reg_score, 'lolos');
                        
                        -- Update used_capacity
                        UPDATE school_registration_path
                        SET used_capacity = used_capacity + 1
                        WHERE school_id_school = school_id 
                          AND registration_path_id_registration_path = path_id;
                    ELSE
                        -- User sudah diterima di prioritas yang lebih baik, masukkan sebagai 'tidak lolos'
                        INSERT INTO final_result (selection_result_registration_id_registration, score, status)
                        VALUES (reg_id, reg_score, 'tidak lolos');
                    END IF;
                ELSE
                    -- Jika slot penuh, masukkan pendaftaran dengan status 'tidak lolos'
                    INSERT INTO final_result (selection_result_registration_id_registration, score, status)
                    VALUES (reg_id, reg_score, 'tidak lolos');
                END IF;
            END LOOP registration_loop;
            CLOSE reg_cursor;
        END;
    END LOOP priority_loop;
    CLOSE priority_cursor;
END //

DELIMITER ;

-- cara memanggil procedure

CALL ProcessSelection();

-- cara select untuk mengetahui final result

SELECT 
    u.id_user,
    r.id_registration,
    u.name,
    r.priority,
    fr.score,
    fr.status
FROM registration r
JOIN `user` u ON r.user_id_user = u.id_user
JOIN final_result fr ON r.id_registration = fr.selection_result_registration_id_registration
ORDER BY r.priority ASC, fr.score DESC;