-- reset data global

DELETE FROM registration;
DELETE FROM school_registration_path;
DELETE FROM registration_path;
DELETE FROM school;
DELETE FROM user;

UPDATE school_registration_path SET used_capacity = 0;
DELETE FROM final_result;
DELETE FROM selection_result;

-- reset data solution

DROP TABLE temp_priority_1;
DROP TABLE temp_priority_2;

DROP INDEX idx_registration_school ON registration;
DROP INDEX idx_selection_result_registration ON selection_result;
DROP INDEX idx_final_result_registration ON final_result;

-- reset data set & optimation

DROP TABLE accepted_users;
DROP TABLE not_accepted_priority1_users;
DROP TABLE not_accepted_priority2_users;

DROP INDEX idx_registration_school ON registration;
DROP INDEX idx_selection_result_registration ON selection_result;
DROP INDEX idx_final_result_registration ON final_result;

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

-- hitung total lolos dan tidak lolos

SELECT 
    COUNT(*) AS total_peserta,
    SUM(CASE WHEN status = 'lolos' THEN 1 ELSE 0 END) AS jumlah_lolos,
    SUM(CASE WHEN status = 'tidak lolos' THEN 1 ELSE 0 END) AS jumlah_tidak_lolos
FROM selection_result;

SELECT 
    COUNT(*) AS total_peserta,
    SUM(CASE WHEN status = 'lolos' THEN 1 ELSE 0 END) AS jumlah_lolos
FROM final_result;

-- hitung kapasitas terpakai

SELECT 
    SUM(capacity) AS total_kapasitas, 
    SUM(used_capacity) AS kapasitas_terpakai
FROM school_registration_path;

-- tampilkan hasil

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

-- hitung semua data

WITH

    -- Hitung total kapasitas dan kapasitas terpakai
    kapasitas AS (
        SELECT 
            SUM(capacity) AS total_kapasitas,
            SUM(used_capacity) AS kapasitas_terpakai
        FROM school_registration_path
    ),

    -- Hitung total peserta, lolos, dan tidak lolos
    peserta AS (
        SELECT 
            COUNT(*) AS total_peserta,
            SUM(CASE WHEN status = 'lolos' THEN 1 ELSE 0 END) AS jumlah_lolos,
            SUM(CASE WHEN status = 'tidak lolos' THEN 1 ELSE 0 END) AS jumlah_tidak_lolos
        FROM selection_result
    ),

    -- Hitung jumlah lolos berdasarkan priority
    lolos_priority AS (
        SELECT 
            SUM(CASE WHEN r.priority = 1 THEN 1 ELSE 0 END) AS lolos_priority_1,
            SUM(CASE WHEN r.priority = 2 THEN 1 ELSE 0 END) AS lolos_priority_2
        FROM final_result fr
        JOIN registration r ON fr.selection_result_registration_id_registration = r.id_registration
    ),

    -- Cek duplikat id_user di final_result
    duplikat AS (
        SELECT 
            u.id_user,
            COUNT(*) AS jumlah_duplikat
        FROM final_result fr
        JOIN registration r ON fr.selection_result_registration_id_registration = r.id_registration
        JOIN `user` u ON r.user_id_user = u.id_user
        GROUP BY u.id_user
        HAVING COUNT(*) > 1
    )

SELECT 
    k.total_kapasitas,
    k.kapasitas_terpakai,
    p.total_peserta,
    p.jumlah_lolos,
    p.jumlah_tidak_lolos,
    lp.lolos_priority_1,
    lp.lolos_priority_2,
    COALESCE(d.jumlah_duplikat, 0) AS jumlah_duplikat
FROM kapasitas k, peserta p, lolos_priority lp
LEFT JOIN (
    SELECT COUNT(*) AS jumlah_duplikat
    FROM duplikat
) d ON 1=1;