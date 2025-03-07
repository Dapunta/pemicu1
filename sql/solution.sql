-- resetter

UPDATE school_registration_path SET used_capacity = 0;
DELETE FROM final_result;
DROP TABLE temp_priority_1;
DROP TABLE temp_priority_2;

-- Tambahkan indeks pada kolom yang sering di-join untuk meningkatkan performa:

CREATE INDEX idx_registration_school_path ON registration (
    school_registration_path_school_id_school,
    school_registration_path_registration_path_id_registration_path
);
CREATE INDEX idx_selection_result_status ON selection_result(status);

-- Langkah 1.1: Urutkan siswa prioritas 1 berdasarkan skor

CREATE TEMPORARY TABLE temp_priority_1 AS
SELECT 
    r.id_registration,
    r.user_id_user,
    r.school_registration_path_school_id_school AS school_id,
    r.school_registration_path_registration_path_id_registration_path AS path_id,
    sr.score,
    ROW_NUMBER() OVER (
        PARTITION BY 
            r.school_registration_path_school_id_school, 
            r.school_registration_path_registration_path_id_registration_path
        ORDER BY sr.score DESC
    ) AS ranking
FROM registration r
JOIN selection_result sr 
    ON r.id_registration = sr.registration_id_registration
WHERE 
    r.priority = 1 
    AND sr.status = 'lolos';

SELECT * FROM temp_priority_1;

-- Langkah 1.2: Insert ke final_result untuk siswa prioritas 1 yang memenuhi kapasitas

START TRANSACTION;

-- Insert ke final_result
INSERT INTO final_result (selection_result_registration_id_registration, score, status)
SELECT 
    t.id_registration,
    t.score,
    'lolos'
FROM temp_priority_1 t
JOIN school_registration_path srp 
    ON t.school_id = srp.school_id_school 
    AND t.path_id = srp.registration_path_id_registration_path
WHERE 
    t.ranking <= (srp.capacity - srp.used_capacity);

-- Update used_capacity
UPDATE school_registration_path srp
JOIN (
    SELECT 
        r.school_registration_path_school_id_school AS school_id,
        r.school_registration_path_registration_path_id_registration_path AS path_id,
        COUNT(*) AS jumlah_lolos
    FROM final_result fr
    JOIN registration r 
        ON fr.selection_result_registration_id_registration = r.id_registration
    WHERE 
        r.priority = 1
    GROUP BY 
        r.school_registration_path_school_id_school, 
        r.school_registration_path_registration_path_id_registration_path
) fr ON srp.school_id_school = fr.school_id
    AND srp.registration_path_id_registration_path = fr.path_id
SET srp.used_capacity = srp.used_capacity + fr.jumlah_lolos;

COMMIT;

SELECT * FROM final_result;

-- Langkah 1.3: Update status siswa yang sudah diterima di prioritas 1 ke "tidak lolos" untuk prioritas > 1

-- update status pada selection_result menjadi 'tidak lolos' jika siswa sudah diterima di priority 1
UPDATE selection_result sr
JOIN registration r 
    ON sr.registration_id_registration = r.id_registration
SET sr.status = 'tidak lolos'
WHERE r.user_id_user IN (
    SELECT DISTINCT r.user_id_user
    FROM registration r
    INNER JOIN final_result fr 
        ON r.id_registration = fr.selection_result_registration_id_registration
)
AND r.priority > 1;

-- update status pada selection_result menjadi 'tidak lolos' jika kapasitas kelas penuh
UPDATE selection_result sr
JOIN registration r 
    ON sr.registration_id_registration = r.id_registration
SET sr.status = 'tidak lolos'
WHERE r.user_id_user NOT IN (
    SELECT DISTINCT r.user_id_user
    FROM registration r
    INNER JOIN final_result fr 
        ON r.id_registration = fr.selection_result_registration_id_registration
)
AND r.priority = 1;

SELECT * FROM selection_result;

-- Langkah 2.1: Urutkan siswa prioritas 2 berdasarkan skor

CREATE TEMPORARY TABLE temp_priority_2 AS
SELECT 
    r.id_registration,
    r.user_id_user,
    r.school_registration_path_school_id_school AS school_id,
    r.school_registration_path_registration_path_id_registration_path AS path_id,
    sr.score,
    ROW_NUMBER() OVER (
        PARTITION BY 
            r.school_registration_path_school_id_school, 
            r.school_registration_path_registration_path_id_registration_path
        ORDER BY sr.score DESC
    ) AS ranking
FROM registration r
JOIN selection_result sr 
    ON r.id_registration = sr.registration_id_registration
WHERE 
    r.priority = 2 
    AND sr.status = 'lolos';

SELECT * FROM temp_priority_2;

-- Langkah 2.2: Insert ke final_result untuk siswa prioritas 2 yang memenuhi kapasitas

START TRANSACTION;

-- Insert ke final_result
INSERT INTO final_result (selection_result_registration_id_registration, score, status)
SELECT 
    t.id_registration,
    t.score,
    'lolos'
FROM temp_priority_2 t
JOIN school_registration_path srp 
    ON t.school_id = srp.school_id_school 
    AND t.path_id = srp.registration_path_id_registration_path
WHERE 
    t.ranking <= (srp.capacity - srp.used_capacity);

-- Update used_capacity
UPDATE school_registration_path srp
JOIN (
    SELECT 
        r.school_registration_path_school_id_school AS school_id,
        r.school_registration_path_registration_path_id_registration_path AS path_id,
        COUNT(*) AS jumlah_lolos
    FROM final_result fr
    JOIN registration r 
        ON fr.selection_result_registration_id_registration = r.id_registration
    WHERE 
        r.priority = 2
    GROUP BY 
        r.school_registration_path_school_id_school, 
        r.school_registration_path_registration_path_id_registration_path
) fr ON srp.school_id_school = fr.school_id
    AND srp.registration_path_id_registration_path = fr.path_id
SET srp.used_capacity = srp.used_capacity + fr.jumlah_lolos;

COMMIT;

SELECT * FROM final_result;

-- bersihkan temporary table

DROP TABLE temp_priority_1;
DROP TABLE temp_priority_2;

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

-- cek apakah ada hasil duplikat

SELECT 
    u.id_user,
    r.id_registration,
    u.name,
    fr.score,
    fr.status
FROM final_result fr
JOIN registration r ON fr.selection_result_registration_id_registration = r.id_registration
JOIN `user` u ON r.user_id_user = u.id_user
WHERE u.id_user IN (
    SELECT u.id_user
    FROM final_result fr
    JOIN registration r ON fr.selection_result_registration_id_registration = r.id_registration
    JOIN `user` u ON r.user_id_user = u.id_user
    GROUP BY u.id_user
    HAVING COUNT(*) > 1
)
ORDER BY u.id_user, fr.score DESC;