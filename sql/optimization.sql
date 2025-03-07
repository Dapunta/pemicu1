-- [ Optimasi Solusi 1 ]

-- 1. Tambahkan Index untuk Mempercepat Partisi dan Join

CREATE INDEX idx_registration_school_path ON registration (
    school_registration_path_school_id_school, 
    school_registration_path_registration_path_id_registration_path
);

CREATE INDEX idx_selection_result_status ON selection_result(status);

-- 2. Gunakan Batch Processing untuk Update Kapasitas

-- Ganti UPDATE dengan perintah per batch
UPDATE school_registration_path srp
SET srp.used_capacity = (
    SELECT COUNT(*)
    FROM final_result fr
    WHERE fr.school_registration_path_school_id_school = srp.school_id_school
        AND fr.school_registration_path_registration_path_id_registration_path = srp.registration_path_id_registration_path
);

-- Hindari CTE jika Tidak Diperlukan:
-- Ganti WITH RankedStudents dengan subquery langsung di INSERT INTO final_result

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- [ Optimasi Solusi 2 ]

-- 1. Gunakan Batasan Kapasitas di Subquery

-- Tambahkan kondisi kapasitas langsung di PARTITION BY
PARTITION BY r.school_registration_path_school_id_school, 
             r.school_registration_path_registration_path_id_registration_path
ORDER BY sr.score DESC, r.priority ASC

-- 2. Gunakan Index Covering

CREATE INDEX idx_registration_priority ON registration(priority);
CREATE INDEX idx_selection_result_score ON selection_result(score);

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- [ Optimasi Solusi 3 ]

-- 1. Hapus Temporary Table Setelah Operasi

DROP TEMPORARY TABLE IF EXISTS TempFinalResult;

-- 2. Gunakan LIMIT dengan Subquery

LIMIT (SELECT capacity - used_capacity FROM school_registration_path WHERE ...);