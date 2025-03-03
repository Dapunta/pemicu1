-- table school
-- berisi data sekolah yang ada di provinsi Sulawesi Selatan
INSERT INTO school (id_school, name, type) VALUES
('SCH000000000000', 'SMA N 1 Bone', 'SMA'),
('SCH000000000001', 'SMK N 3 Bone', 'SMK'),
('SCH000000000002', 'SMA N 2 Gowa', 'SMA'),
('SCH000000000003', 'SMK N 4 Gowa', 'SMK'),
('SCH000000000004', 'SMA N 1 Selayar', 'SMA'),
('SCH000000000005', 'SMK N 4 Selayar', 'SMK'),
('SCH000000000006', 'SMA N 2 Luwu Timur', 'SMA'),
('SCH000000000007', 'SMK N 3 Luwu Timur', 'SMK'),
('SCH000000000008', 'SMA N 1 Maros', 'SMA'),
('SCH000000000009', 'SMK N 2 Maros', 'SMK');

-- table registration_path
-- berisi data jalur pendaftaran yang tersedia
INSERT INTO registration_path (id_registration_path, name) VALUES
('SMU000241223001', 'afirmasi'),
('SMU000161022002', 'perpindahan tugas orang tua/wali'),
('SMU000200823003', 'prestasi non akademik'),
('SMU000111124004', 'anak guru'),
('SMA000010124001', 'boarding school'),
('SMK000010124001', 'anak DUDI mitra SMK'),
('SMK000241223002', 'domisili terdekat dari sekolah');

-- table school_registration_path
-- table penghubung relasi many-to-many antara table school dan registration_path
-- berisi data sekolah dan jalur yang dibuka
INSERT INTO school_registration_path (school_id_school, registration_path_id_registration_path, capacity, used_capacity) VALUES
('SCH000000000000', 'SMU000241223001', '20', '0'),
('SCH000000000000', 'SMU000200823003', '40', '0'),
('SCH000000000001', 'SMU000241223001', '30', '0'),
('SCH000000000001', 'SMU000200823003', '60', '0'),
('SCH000000000002', 'SMU000241223001', '25', '0'),
('SCH000000000002', 'SMU000200823003', '50', '0'),
('SCH000000000003', 'SMU000241223001', '28', '0'),
('SCH000000000003', 'SMU000200823003', '56', '0'),
('SCH000000000004', 'SMU000241223001', '30', '0'),
('SCH000000000004', 'SMU000200823003', '60', '0'),
('SCH000000000005', 'SMU000241223001', '32', '0'),
('SCH000000000005', 'SMU000200823003', '64', '0'),
('SCH000000000006', 'SMU000241223001', '15', '0'),
('SCH000000000006', 'SMU000200823003', '30', '0'),
('SCH000000000007', 'SMU000241223001', '10', '0'),
('SCH000000000007', 'SMU000200823003', '20', '0'),
('SCH000000000008', 'SMU000241223001', '12', '0'),
('SCH000000000008', 'SMU000200823003', '24', '0'),
('SCH000000000009', 'SMU000241223001', '16', '0'),
('SCH000000000009', 'SMU000200823003', '32', '0');

-- table user
-- berisi data peserta calon didik baru yang mendaftar
INSERT INTO user (id_user, name, nisn, email, phone_number, password, address, registration_time, verified) VALUES
('USR000000000001', 'Dapunta Ratya', '5025231187', 'dapunta09091@gmail.com', '6282200000000', 'palestinehargamati987', 'Yogyakarta, Indonesia', TO_DATE('2023-06-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '1'),
('USR000000000002', 'Suci Maharani', '5043241120', 'sucirani4465@gmail.com', '6282200000001', 'palestinehargamati789', 'Surabaya, Indonesia', TO_DATE('2023-06-16 23:59:59', 'YYYY-MM-DD HH24:MI:SS'), '1');

-- table registration
-- berisi data pendaftaran
INSERT INTO registration (id_registration, user_id_user, school_registration_path_school_id_school, school_registration_path_registration_path_id_registration_path, registration_time, priority) VALUES
('RGS000000000001', 'USR000000000001', 'SCH000000000002', 'SMU000200823003', TO_DATE('2023-06-19 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '2'),
('RGS000000000002', 'USR000000000001', 'SCH000000000000', 'SMU000200823003', TO_DATE('2023-06-20 01:01:01', 'YYYY-MM-DD HH24:MI:SS'), '1'),
('RGS000000000003', 'USR000000000002', 'SCH000000000007', 'SMU000241223001', TO_DATE('2023-06-19 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), '2'),
('RGS000000000004', 'USR000000000002', 'SCH000000000008', 'SMU000200823003', TO_DATE('2023-06-20 01:01:01', 'YYYY-MM-DD HH24:MI:SS'), '1');

-- table selection_result
-- berisi data mentah, peserta lolos, belum disortir (1 anak bisa lolos di 2 sekolah)
INSERT INTO selection_result (registration_id_registration, score, status) VALUES
('RGS000174247052', '784', 'lolos'),
('RGS000861967600', '682', 'tidak lolos');

-- table final_result
-- berisi data final, peserta lolos, sudah disortir (1 anak hanya lolos di 1 sekolah)
INSERT INTO final_result (selection_result_registration_id_registration, score, status) VALUES
