-- optimasi indeks
CREATE INDEX idx_registration_school ON registration(school_registration_path_school_id_school, school_registration_path_registration_path_id_registration_path);
CREATE INDEX idx_selection_result_registration ON selection_result(registration_id_registration);
CREATE INDEX idx_final_result_registration ON final_result(selection_result_registration_id_registration);

-- proses sorting priority 1
INSERT INTO final_result (selection_result_registration_id_registration, score, status)
SELECT 
    ranked_data.id_registration,
    ranked_data.score,
    'lolos'
FROM (
    SELECT 
        r.id_registration,
        sr.score,
        srp.capacity - srp.used_capacity AS remaining_capacity,
        ROW_NUMBER() OVER (
            PARTITION BY 
                r.school_registration_path_school_id_school, 
                r.school_registration_path_registration_path_id_registration_path
            ORDER BY sr.score DESC
        ) AS `row_rank`
    FROM registration r
    JOIN selection_result sr 
        ON r.id_registration = sr.registration_id_registration
    JOIN school_registration_path srp 
        ON r.school_registration_path_school_id_school = srp.school_id_school
        AND r.school_registration_path_registration_path_id_registration_path = srp.registration_path_id_registration_path
    WHERE 
        r.priority = 1 
        AND sr.status = 'lolos'
) AS ranked_data
WHERE `row_rank` <= remaining_capacity;

-- update kapasitas dengan operasi set
WITH capacity_update_1 AS (
    SELECT 
        school_registration_path_school_id_school AS school_id,
        school_registration_path_registration_path_id_registration_path AS path_id,
        COUNT(*) AS total
    FROM final_result
    JOIN registration ON final_result.selection_result_registration_id_registration = registration.id_registration
    WHERE priority = 1
    GROUP BY 1,2
)
UPDATE school_registration_path srp
JOIN capacity_update_1 cu 
    ON srp.school_id_school = cu.school_id
    AND srp.registration_path_id_registration_path = cu.path_id
SET srp.used_capacity = srp.used_capacity + cu.total;

-- update status dengan operasi set
UPDATE selection_result sr
JOIN registration r ON sr.registration_id_registration = r.id_registration
SET sr.status = 'tidak lolos'
WHERE 
    (
        r.priority > 1
        AND EXISTS (
            SELECT 1
            FROM final_result fr
            WHERE fr.selection_result_registration_id_registration IN (
                SELECT r2.id_registration
                FROM registration r2
                WHERE r2.user_id_user = r.user_id_user
            )
        )
    )
    OR
    (
        r.priority = 1
        AND NOT EXISTS (
            SELECT 1
            FROM final_result fr
            WHERE fr.selection_result_registration_id_registration IN (
                SELECT r2.id_registration
                FROM registration r2
                WHERE r2.user_id_user = r.user_id_user
            )
        )
    );

-- proses sorting priority 2
INSERT INTO final_result (selection_result_registration_id_registration, score, status)
SELECT 
    ranked_data.id_registration,
    ranked_data.score,
    'lolos'
FROM (
    SELECT 
        r.id_registration,
        sr.score,
        srp.capacity - srp.used_capacity AS remaining_capacity,
        ROW_NUMBER() OVER (
            PARTITION BY 
                r.school_registration_path_school_id_school, 
                r.school_registration_path_registration_path_id_registration_path
            ORDER BY sr.score DESC
        ) AS `row_rank`
    FROM registration r
    JOIN selection_result sr 
        ON r.id_registration = sr.registration_id_registration
    JOIN school_registration_path srp 
        ON r.school_registration_path_school_id_school = srp.school_id_school
        AND r.school_registration_path_registration_path_id_registration_path = srp.registration_path_id_registration_path
    WHERE 
        r.priority = 2 
        AND sr.status = 'lolos'
) AS ranked_data
WHERE `row_rank` <= remaining_capacity;

-- update kapasitas dengan operasi set
WITH capacity_update_2 AS (
    SELECT 
        school_registration_path_school_id_school AS school_id,
        school_registration_path_registration_path_id_registration_path AS path_id,
        COUNT(*) AS total
    FROM final_result
    JOIN registration ON final_result.selection_result_registration_id_registration = registration.id_registration
    WHERE priority = 2
    GROUP BY 1,2
)
UPDATE school_registration_path srp
JOIN capacity_update_2 cu 
    ON srp.school_id_school = cu.school_id
    AND srp.registration_path_id_registration_path = cu.path_id
SET srp.used_capacity = srp.used_capacity + cu.total;

-- update status dengan operasi set
UPDATE selection_result sr
JOIN registration r ON sr.registration_id_registration = r.id_registration
SET sr.status = 'tidak lolos'
WHERE 
    (
        r.priority > 2
        AND EXISTS (
            SELECT 1
            FROM final_result fr
            WHERE fr.selection_result_registration_id_registration IN (
                SELECT r2.id_registration
                FROM registration r2
                WHERE r2.user_id_user = r.user_id_user
            )
        )
    )
    OR
    (
        r.priority = 2
        AND NOT EXISTS (
            SELECT 1
            FROM final_result fr
            WHERE fr.selection_result_registration_id_registration IN (
                SELECT r2.id_registration
                FROM registration r2
                WHERE r2.user_id_user = r.user_id_user
            )
        )
    );