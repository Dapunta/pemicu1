-- reset data

UPDATE school_registration_path SET used_capacity = 0;

DELETE FROM final_result;
DELETE FROM selection_result;
DELETE FROM registration;
DELETE FROM school_registration_path;
DELETE FROM registration_path;
DELETE FROM school;
DELETE FROM user;

DROP TABLE temp_priority_1;
DROP TABLE temp_priority_2;

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