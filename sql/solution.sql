-- urutkan siswa prioritas 1 berdasarkan skor
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

-- insert ke final_result untuk siswa prioritas 1 yang memenuhi kapasitas
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

-- update used_capacity
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

-- update status siswa yang sudah diterima di prioritas 1 ke "tidak lolos" jika prioritas > 1
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

-- update status siswa yang tidak diterima di prioritas 1 karena kapasitas penuh
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

-- urutkan siswa prioritas 2 berdasarkan skor
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

-- insert ke final_result untuk siswa prioritas 2 yang memenuhi kapasitas
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

-- update used_capacity
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

-- update status siswa yang sudah diterima di prioritas 2 ke "tidak lolos" jika prioritas > 2
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
AND r.priority > 2;

-- update status siswa yang tidak diterima di prioritas 2 karena kapasitas penuh
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
AND r.priority = 2;