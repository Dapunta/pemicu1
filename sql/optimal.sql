-- optimasi indeks
CREATE INDEX idx_registration_school ON registration(school_registration_path_school_id_school, school_registration_path_registration_path_id_registration_path);
CREATE INDEX idx_selection_result_registration ON selection_result(registration_id_registration);
CREATE INDEX idx_final_result_registration ON final_result(selection_result_registration_id_registration);

-- proses sorting priority 1
INSERT INTO final_result (selection_result_registration_id_registration, score, status)
WITH RankedPriority1 AS (
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
    JOIN selection_result sr ON r.id_registration = sr.registration_id_registration
    WHERE 
        r.priority = 1 
        AND sr.status = 'lolos'
)
SELECT 
    rp.id_registration,
    rp.score,
    'lolos'
FROM RankedPriority1 rp
JOIN school_registration_path srp 
    ON rp.school_id = srp.school_id_school 
    AND rp.path_id = srp.registration_path_id_registration_path
WHERE 
    rp.ranking <= (srp.capacity - srp.used_capacity);

-- update kapasitas kelas setelah sorting priority 1
UPDATE school_registration_path srp
JOIN (
    SELECT 
        r.school_registration_path_school_id_school,
        r.school_registration_path_registration_path_id_registration_path,
        COUNT(*) AS jumlah_lolos
    FROM final_result fr
    JOIN registration r ON fr.selection_result_registration_id_registration = r.id_registration
    WHERE r.priority = 1
    GROUP BY 
        r.school_registration_path_school_id_school, 
        r.school_registration_path_registration_path_id_registration_path
) fr ON srp.school_id_school = fr.school_registration_path_school_id_school
    AND srp.registration_path_id_registration_path = fr.school_registration_path_registration_path_id_registration_path
SET srp.used_capacity = srp.used_capacity + fr.jumlah_lolos;

-- update status pada selection_result setelah priority 1

UPDATE selection_result sr -- sudah diterima di prioritas 1 dan jumlah prioritas > 1
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

UPDATE selection_result sr -- tidak diterima di prioritas 1 karena kapasitas penuh
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

-- proses sorting priority 2
INSERT INTO final_result (selection_result_registration_id_registration, score, status)
WITH RankedPriority2 AS (
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
    JOIN selection_result sr ON r.id_registration = sr.registration_id_registration
    WHERE 
        r.priority = 2
        AND sr.status = 'lolos'
)
SELECT 
    rp.id_registration,
    rp.score,
    'lolos'
FROM RankedPriority2 rp
JOIN school_registration_path srp 
    ON rp.school_id = srp.school_id_school 
    AND rp.path_id = srp.registration_path_id_registration_path
WHERE 
    rp.ranking <= (srp.capacity - srp.used_capacity);

-- update kapasitas kelas setelah sorting priority 2
UPDATE school_registration_path srp
JOIN (
    SELECT 
        r.school_registration_path_school_id_school,
        r.school_registration_path_registration_path_id_registration_path,
        COUNT(*) AS jumlah_lolos
    FROM final_result fr
    JOIN registration r ON fr.selection_result_registration_id_registration = r.id_registration
    WHERE r.priority = 2
    GROUP BY 
        r.school_registration_path_school_id_school, 
        r.school_registration_path_registration_path_id_registration_path
) fr ON srp.school_id_school = fr.school_registration_path_school_id_school
    AND srp.registration_path_id_registration_path = fr.school_registration_path_registration_path_id_registration_path
SET srp.used_capacity = srp.used_capacity + fr.jumlah_lolos;

-- update status pada selection_result setelah priority 2

UPDATE selection_result sr -- sudah diterima di prioritas 2 dan jumlah prioritas > 2
JOIN registration r 
    ON sr.registration_id_registration = r.id_registration
SET sr.status = 'tidak lolos'
WHERE r.user_id_user IN (
    SELECT DISTINCT r.user_id_user
    FROM registration r
    INNER JOIN final_result fr 
        ON r.id_registration = fr.selection_result_registration_id_registration
)
AND r.priority > 2;

UPDATE selection_result sr -- tidak diterima di prioritas 2 karena kapasitas penuh
JOIN registration r 
    ON sr.registration_id_registration = r.id_registration
SET sr.status = 'tidak lolos'
WHERE r.user_id_user NOT IN (
    SELECT DISTINCT r.user_id_user
    FROM registration r
    INNER JOIN final_result fr 
        ON r.id_registration = fr.selection_result_registration_id_registration
)
AND r.priority = 2;