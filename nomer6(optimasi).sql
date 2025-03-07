-- Tambahkan indeks (jika belum ada)
CREATE INDEX idx_registration_school_path ON registration (
    school_registration_path_school_id_school,
    school_registration_path_registration_path_id_registration_path
);
CREATE INDEX idx_selection_result_status ON selection_result(status);

-- Mulai transaksi agar operasi INSERT dan UPDATE kapasitas berjalan secara atomik
START TRANSACTION;

-- Langkah 1: Insert data ke final_result tanpa membuat temporary table
INSERT INTO final_result (selection_result_registration_id_registration, score, status)
WITH temp_priority_1 AS (
    SELECT 
         r.id_registration,
         r.user_id_user,
         r.school_registration_path_school_id_school AS school_id,
         r.school_registration_path_registration_path_id_registration_path AS path_id,
         sr.score,
         ROW_NUMBER() OVER (
              PARTITION BY r.school_registration_path_school_id_school, 
                           r.school_registration_path_registration_path_id_registration_path
              ORDER BY sr.score DESC
         ) AS ranking
    FROM registration r
    JOIN selection_result sr ON r.id_registration = sr.registration_id_registration
    WHERE r.priority = 1 
      AND sr.status = 'lolos'
)
SELECT 
    t.id_registration,
    t.score,
    'lolos'
FROM temp_priority_1 t
JOIN school_registration_path srp 
    ON t.school_id = srp.school_id_school 
   AND t.path_id = srp.registration_path_id_registration_path
WHERE t.ranking <= (srp.capacity - srp.used_capacity);

-- Langkah 2: Update kolom used_capacity pada school_registration_path
UPDATE school_registration_path srp
JOIN (
    SELECT 
       r.school_registration_path_school_id_school AS school_id,
       r.school_registration_path_registration_path_id_registration_path AS path_id,
       COUNT(*) AS jumlah_lolos
    FROM registration r
    JOIN final_result fr ON r.id_registration = fr.selection_result_registration_id_registration
    WHERE r.priority = 1
    GROUP BY r.school_registration_path_school_id_school, 
             r.school_registration_path_registration_path_id_registration_path
) cc ON srp.school_id_school = cc.school_id 
    AND srp.registration_path_id_registration_path = cc.path_id
SET srp.used_capacity = srp.used_capacity + cc.jumlah_lolos;

COMMIT;

-- Langkah 3: Update status pendaftaran di selection_result untuk siswa dengan prioritas > 1
UPDATE selection_result sr
JOIN registration r ON sr.registration_id_registration = r.id_registration
SET sr.status = 'tidak lolos'
WHERE r.priority > 1
  AND r.user_id_user IN (
      SELECT user_id_user FROM (
          SELECT DISTINCT r2.user_id_user
          FROM registration r2
          JOIN final_result fr2 ON r2.id_registration = fr2.selection_result_registration_id_registration
      ) accepted_users
  );

-- (Optional) Tampilkan hasil akhir
SELECT * FROM final_result;
SELECT * FROM selection_result;
