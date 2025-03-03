import re, random, string
from faker import Faker

fake = Faker()

list_kabupaten = [
    'Bantaeng',
    'Barru',
    'Bone',
    'Bulukumba',
    'Enrekang',
    'Gowa',
    'Jeneponto',
    'Kepulauan Selayar',
    'Luwu',
    'Luwu Timur',
    'Luwu Utara',
    'Maros',
    'Pangkajene',
    'Pinrang',
    'Sidanreng Rappang',
    'Sinjai',
    'Soppeng',
    'Takalar',
    'Tana Toraja',
    'Toraja Utara',
    'Wajo',
    'Makassar',
    'Parepare',
    'Palopo',
]

def random_time():
    hh = random.randint(0, 23)
    mm = random.randint(0, 59)
    ss = random.randint(0, 59)
    return f"{hh:02d}:{mm:02d}:{ss:02d}"

def table_user():

    jumlah_data = 1000
    for i in range(jumlah_data):

        id_user = 'USR000' + str(random.randint(111111111,999999999))
        name = fake.name()
        nisn = '0000' + str(random.randint(111111,999999))
        email = '{}{}@gmail.com'.format(name.replace(' ','').lower(), str(random.randint(111,999)))
        phone_number = '628' + str(random.randint(1111111111,9999999999))
        password = ''.join([random.choice(string.ascii_letters + string.digits) for i in range(12)])
        address = re.sub(r'[\r\n]+', ' ', fake.address())
        status = str(random.choice([0,1]))

        digit_tanggal = str(random.randint(5,16))
        tanggal = '0{}'.format(digit_tanggal) if len(digit_tanggal) < 2 else digit_tanggal
        registration_time = '2023-06-{} {}'.format(tanggal, random_time())

        format_sql = f"('{id_user}', '{name}', '{nisn}', '{email}', '{phone_number}', '{password}', '{address}', TO_DATE('{registration_time}', 'YYYY-MM-DD HH24:MI:SS'), '{status}'),\n"
        # open('insert_data/user.sql', 'a+', encoding='utf-8').write(format_sql)

def table_school():
    
    jenis_sekolah = ['SMA', 'SMK']
    jumlah_sekolah_per_kabupaten_per_jenis = 5

    for lokasi in list_kabupaten:
        for tipe in jenis_sekolah:
            for i in range(1,jumlah_sekolah_per_kabupaten_per_jenis+1):

                id_school = 'SCH000' + str(random.randint(111111111,999999999))
                name = '{} Negeri {} {}'.format(tipe, i, lokasi)

                format_sql = f"('{id_school}', '{name}', '{tipe}'),\n"
                # open('insert_data/school.sql', 'a+', encoding='utf-8').write(format_sql)

def table_school_registration_path():

    data_sekolah = [re.findall(r"'([^']*)'", baris) for baris in open('insert_data/school.sql', 'r').read().splitlines()[3:]]
    data_jalur = [re.findall(r"'([^']*)'", baris) for baris in open('insert_data/registration_path.sql', 'r').read().splitlines()[3:]]

    for item_1 in data_sekolah:
        for item_2 in data_jalur:
            
            if item_1[2] in item_2[0]: condition = True
            elif 'SMU' in item_2[0]: condition = True
            else: condition = False
            
            capacity = random.randint(5,30)

            if condition:
                format_sql = f"('{item_1[0]}', '{item_2[0]}', '{capacity}', '0'),\n"
                # open('insert_data/school_registration_path.sql', 'a+', encoding='utf-8').write(format_sql)

def table_registration():
    
    data_user = [re.findall(r"'([^']*)'", baris) for baris in open('insert_data/user.sql', 'r').read().splitlines()[3:]]
    data_sekolah_dan_jalur = [re.findall(r"'([^']*)'", baris) for baris in open('insert_data/school_registration_path.sql', 'r').read().splitlines()[3:]]

    for item_1 in data_user:
        for priority in range(1,3):
            
            id_registration = 'RGS000' + str(random.randint(111111111,999999999))
            id_user = item_1[0]
            
            random_school_dan_jalur = random.choice(data_sekolah_dan_jalur)
            id_school = random_school_dan_jalur[0]
            id_jalur = random_school_dan_jalur[1]

            tanggal = str(random.randint(19,22))
            registration_time = '2023-06-{} {}'.format(tanggal, random_time())

            format_sql = f"('{id_registration}', '{id_user}', '{id_school}', '{id_jalur}', TO_DATE('{registration_time}', 'YYYY-MM-DD HH24:MI:SS'), '{priority}'),\n"
            # open('insert_data/registration.sql', 'a+', encoding='utf-8').write(format_sql)

def table_selection_result():
    
    data_registration = [re.findall(r"'([^']*)'", baris) for baris in open('insert_data/registration.sql', 'r').read().splitlines()[3:]]
    
    for item in data_registration:
        
        score = random.randint(500, 825)
        status = random.choice(['lolos', 'tidak lolos'])

        format_sql = f"('{item[0]}', '{score}', '{status}'),\n"
        open('insert_data/selection_result.sql', 'a+', encoding='utf-8').write(format_sql)

if __name__ == '__main__':

    #--> table user
    # table_user()

    #--> table school
    # table_school()

    #--> table school_registration_path
    # table_school_registration_path()

    #--> table registration
    # table_registration()

    #--> table selection_result
    # table_selection_result()

    pass