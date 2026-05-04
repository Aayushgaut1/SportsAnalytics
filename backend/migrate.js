const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'sports_admin',
    password: 'sports123',
    database: 'multi_sport_selection',
    waitForConnections: true,
    connectionLimit: 1,
    queueLimit: 0
});

const LEGENDS_DATA = {
    'Cricket': [
        { n: 'Virat Kohli', nat: 'Indian' }, { n: 'Rohit Sharma', nat: 'Indian' }, { n: 'Jasprit Bumrah', nat: 'Indian' }, { n: 'Steve Smith', nat: 'Australian' }, { n: 'Pat Cummins', nat: 'Australian' },
        { n: 'Joe Root', nat: 'British' }, { n: 'Kane Williamson', nat: 'New Zealander' }, { n: 'Babar Azam', nat: 'Pakistani' }, { n: 'Ben Stokes', nat: 'British' }, { n: 'Rashid Khan', nat: 'Afghan' },
        { n: 'Mohammed Shami', nat: 'Indian' }, { n: 'Ravindra Jadeja', nat: 'Indian' }, { n: 'Glenn Maxwell', nat: 'Australian' }, { n: 'David Warner', nat: 'Australian' }, { n: 'Quinton de Kock', nat: 'South African' },
        { n: 'Kagiso Rabada', nat: 'South African' }, { n: 'Trent Boult', nat: 'New Zealander' }, { n: 'Jos Buttler', nat: 'British' }, { n: 'Rishabh Pant', nat: 'Indian' }, { n: 'KL Rahul', nat: 'Indian' },
        { n: 'Mitchell Starc', nat: 'Australian' }, { n: 'Shaheen Afridi', nat: 'Pakistani' }, { n: 'Hardik Pandya', nat: 'Indian' }, { n: 'Travis Head', nat: 'Australian' }, { n: 'Harry Brook', nat: 'British' },
        { n: 'Shubman Gill', nat: 'Indian' }, { n: 'Adam Zampa', nat: 'Australian' }, { n: 'Anrich Nortje', nat: 'South African' }, { n: 'Shakib Al Hasan', nat: 'Bangladeshi' }, { n: 'Wanindu Hasaranga', nat: 'Sri Lankan' },
        { n: 'Daryl Mitchell', nat: 'New Zealander' }, { n: 'Mohammed Siraj', nat: 'Indian' }, { n: 'Kuldeep Yadav', nat: 'Indian' }, { n: 'Nicholas Pooran', nat: 'West Indian' }, { n: 'Liam Livingstone', nat: 'British' },
        { n: 'Sam Curran', nat: 'British' }, { n: 'Suryakumar Yadav', nat: 'Indian' }, { n: 'Axar Patel', nat: 'Indian' }, { n: 'Josh Hazlewood', nat: 'Australian' }, { n: 'Mark Wood', nat: 'British' }
    ],
    'Football': [
        { n: 'Lionel Messi', nat: 'Argentinian' }, { n: 'Cristiano Ronaldo', nat: 'Portuguese' }, { n: 'Kylian Mbappe', nat: 'French' }, { n: 'Erling Haaland', nat: 'Norwegian' }, { n: 'Neymar Jr', nat: 'Brazilian' },
        { n: 'Mohamed Salah', nat: 'Egyptian' }, { n: 'Kevin De Bruyne', nat: 'Belgian' }, { n: 'Luka Modric', nat: 'Croatian' }, { n: 'Robert Lewandowski', nat: 'Polish' }, { n: 'Vinicius Jr', nat: 'Brazilian' },
        { n: 'Jude Bellingham', nat: 'British' }, { n: 'Harry Kane', nat: 'British' }, { n: 'Antoine Griezmann', nat: 'French' }, { n: 'Rodri', nat: 'Spanish' }, { n: 'Bukayo Saka', nat: 'British' },
        { n: 'Son Heung-min', nat: 'Korean' }, { n: 'Alisson Becker', nat: 'Brazilian' }, { n: 'Virgil van Dijk', nat: 'Dutch' }, { n: 'Bernardo Silva', nat: 'Portuguese' }, { n: 'Bruno Fernandes', nat: 'Portuguese' },
        { n: 'Phil Foden', nat: 'British' }, { n: 'Lautaro Martinez', nat: 'Argentinian' }, { n: 'Julian Alvarez', nat: 'Argentinian' }, { n: 'Pedri', nat: 'Spanish' }, { n: 'Gavi', nat: 'Spanish' },
        { n: 'Jamal Musiala', nat: 'German' }, { n: 'Florian Wirtz', nat: 'German' }, { n: 'Victor Osimhen', nat: 'Nigerian' }, { n: 'Rafael Leao', nat: 'Portuguese' }, { n: 'Khvicha Kvaratskhelia', nat: 'Georgian' },
        { n: 'Federico Valverde', nat: 'Uruguayan' }, { n: 'Eduardo Camavinga', nat: 'French' }, { n: 'Alphonso Davies', nat: 'Canadian' }, { n: 'Achraf Hakimi', nat: 'Moroccan' }, { n: 'Theo Hernandez', nat: 'French' },
        { n: 'Ruben Dias', nat: 'Portuguese' }, { n: 'William Saliba', nat: 'French' }, { n: 'Mike Maignan', nat: 'French' }, { n: 'Thibaut Courtois', nat: 'Belgian' }, { n: 'Jan Oblak', nat: 'Slovenian' }
    ],
    'Badminton': [
        { n: 'Lin Dan', nat: 'Chinese' }, { n: 'Lee Chong Wei', nat: 'Malaysian' }, { n: 'Viktor Axelsen', nat: 'Danish' }, { n: 'PV Sindhu', nat: 'Indian' }, { n: 'Tai Tzu-ying', nat: 'Taiwanese' },
        { n: 'Carolina Marin', nat: 'Spanish' }, { n: 'Kento Momota', nat: 'Japanese' }, { n: 'Lakshya Sen', nat: 'Indian' }, { n: 'An Se-young', nat: 'Korean' }, { n: 'Anders Antonsen', nat: 'Danish' },
        { n: 'Anthony Ginting', nat: 'Indonesian' }, { n: 'Jonatan Christie', nat: 'Indonesian' }, { n: 'Kodai Naraoka', nat: 'Japanese' }, { n: 'Loh Kean Yew', nat: 'Singaporean' }, { n: 'Kunlavut Vitidsarn', nat: 'Thai' },
        { n: 'Prannoy HS', nat: 'Indian' }, { n: 'Kidambi Srikanth', nat: 'Indian' }, { n: 'Chou Tien-chen', nat: 'Taiwanese' }, { n: 'Lee Zii Jia', nat: 'Malaysian' }, { n: 'Shi Yuqi', nat: 'Chinese' },
        { n: 'Chen Yufei', nat: 'Chinese' }, { n: 'Akane Yamaguchi', nat: 'Japanese' }, { n: 'Ratchanok Intanon', nat: 'Thai' }, { n: 'Pornpawee Chochuwong', nat: 'Thai' }, { n: 'Gregoria Mariska Tunjung', nat: 'Indonesian' },
        { n: 'Busanan Ongbamrungphan', nat: 'Thai' }, { n: 'Han Yue', nat: 'Chinese' }, { n: 'Wang Zhiyi', nat: 'Chinese' }, { n: 'He Bingjiao', nat: 'Chinese' }, { n: 'Zhang Yiman', nat: 'Chinese' },
        { n: 'Satwiksairaj Rankireddy', nat: 'Indian' }, { n: 'Chirag Shetty', nat: 'Indian' }, { n: 'Aaron Chia', nat: 'Malaysian' }, { n: 'Soh Wooi Yik', nat: 'Malaysian' }, { n: 'Liang Weikeng', nat: 'Chinese' },
        { n: 'Wang Chang', nat: 'Chinese' }, { n: 'Fajar Alfian', nat: 'Indonesian' }, { n: 'Muhammad Rian Ardianto', nat: 'Indonesian' }, { n: 'Takuro Hoki', nat: 'Japanese' }, { n: 'Yugo Kobayashi', nat: 'Japanese' }
    ],
    'Basketball': [
        { n: 'LeBron James', nat: 'American' }, { n: 'Stephen Curry', nat: 'American' }, { n: 'Kevin Durant', nat: 'American' }, { n: 'Giannis Antetokounmpo', nat: 'Greek' }, { n: 'Luka Doncic', nat: 'Slovenian' },
        { n: 'Nikola Jokic', nat: 'Serbian' }, { n: 'Joel Embiid', nat: 'Cameroonian' }, { n: 'Jayson Tatum', nat: 'American' }, { n: 'Victor Wembanyama', nat: 'French' }, { n: 'Shai Gilgeous-Alexander', nat: 'Canadian' },
        { n: 'Devin Booker', nat: 'American' }, { n: 'Anthony Edwards', nat: 'American' }, { n: 'Jimmy Butler', nat: 'American' }, { n: 'Damian Lillard', nat: 'American' }, { n: 'Anthony Davis', nat: 'American' },
        { n: 'Kawhi Leonard', nat: 'American' }, { n: 'Paul George', nat: 'American' }, { n: 'Ja Morant', nat: 'American' }, { n: 'Tyrese Haliburton', nat: 'American' }, { n: 'DeAaron Fox', nat: 'American' },
        { n: 'Bam Adebayo', nat: 'American' }, { n: 'Domantas Sabonis', nat: 'Lithuanian' }, { n: 'Lauri Markkanen', nat: 'Finnish' }, { n: 'Jalen Brunson', nat: 'American' }, { n: 'Donovan Mitchell', nat: 'American' },
        { n: 'Trae Young', nat: 'American' }, { n: 'Jaylen Brown', nat: 'American' }, { n: 'Karl-Anthony Towns', nat: 'Dominican' }, { n: 'Rudy Gobert', nat: 'French' }, { n: 'Chet Holmgren', nat: 'American' },
        { n: 'Paolo Banchero', nat: 'Italian' }, { n: 'Cade Cunningham', nat: 'American' }, { n: 'Zion Williamson', nat: 'American' }, { n: 'Kyrie Irving', nat: 'American' }, { n: 'James Harden', nat: 'American' },
        { n: 'Klay Thompson', nat: 'American' }, { n: 'Draymond Green', nat: 'American' }, { n: 'Chris Paul', nat: 'American' }, { n: 'Russell Westbrook', nat: 'American' }, { n: 'Pascal Siakam', nat: 'Cameroonian' }
    ],
    'F1': [
        { n: 'Lewis Hamilton', nat: 'British' }, { n: 'Max Verstappen', nat: 'Dutch' }, { n: 'Charles Leclerc', nat: 'Monegasque' }, { n: 'Fernando Alonso', nat: 'Spanish' }, { n: 'Lando Norris', nat: 'British' },
        { n: 'George Russell', nat: 'British' }, { n: 'Sergio Perez', nat: 'Mexican' }, { n: 'Oscar Piastri', nat: 'Australian' }, { n: 'Carlos Sainz', nat: 'Spanish' }, { n: 'Daniel Ricciardo', nat: 'Australian' },
        { n: 'Pierre Gasly', nat: 'French' }, { n: 'Esteban Ocon', nat: 'French' }, { n: 'Alex Albon', nat: 'Thai' }, { n: 'Valtteri Bottas', nat: 'Finnish' }, { n: 'Kevin Magnussen', nat: 'Danish' },
        { n: 'Nico Hulkenberg', nat: 'German' }, { n: 'Yuki Tsunoda', nat: 'Japanese' }, { n: 'Lance Stroll', nat: 'Canadian' }, { n: 'Logan Sargeant', nat: 'American' }, { n: 'Guanyu Zhou', nat: 'Chinese' },
        { n: 'Liam Lawson', nat: 'New Zealander' }, { n: 'Nyck de Vries', nat: 'Dutch' }, { n: 'Sebastian Vettel', nat: 'German' }, { n: 'Kimi Raikkonen', nat: 'Finnish' }, { n: 'Michael Schumacher', nat: 'German' },
        { n: 'Ayrton Senna', nat: 'Brazilian' }, { n: 'Alain Prost', nat: 'French' }, { n: 'Niki Lauda', nat: 'Austrian' }, { n: 'James Hunt', nat: 'British' }, { n: 'Jackie Stewart', nat: 'British' },
        { n: 'Oliver Bearman', nat: 'British' }, { n: 'Felipe Massa', nat: 'Brazilian' }, { n: 'Rubens Barrichello', nat: 'Brazilian' }, { n: 'Mark Webber', nat: 'Australian' }, { n: 'David Coulthard', nat: 'British' },
        { n: 'Jenson Button', nat: 'British' }, { n: 'Nico Rosberg', nat: 'German' }, { n: 'Mick Schumacher', nat: 'German' }, { n: 'Jack Doohan', nat: 'Australian' }, { n: 'Robert Kubica', nat: 'Polish' }
    ],
    'Tennis': [
        { n: 'Novak Djokovic', nat: 'Serbian' }, { n: 'Rafael Nadal', nat: 'Spanish' }, { n: 'Roger Federer', nat: 'Swiss' }, { n: 'Carlos Alcaraz', nat: 'Spanish' }, { n: 'Jannik Sinner', nat: 'Italian' },
        { n: 'Daniil Medvedev', nat: 'Russian' }, { n: 'Iga Swiatek', nat: 'Polish' }, { n: 'Aryna Sabalenka', nat: 'Belarusian' }, { n: 'Coco Gauff', nat: 'American' }, { n: 'Stefanos Tsitsipas', nat: 'Greek' },
        { n: 'Alexander Zverev', nat: 'German' }, { n: 'Holger Rune', nat: 'Danish' }, { n: 'Casper Ruud', nat: 'Norwegian' }, { n: 'Andrey Rublev', nat: 'Russian' }, { n: 'Hubert Hurkacz', nat: 'Polish' },
        { n: 'Grigor Dimitrov', nat: 'Bulgarian' }, { n: 'Taylor Fritz', nat: 'American' }, { n: 'Ben Shelton', nat: 'American' }, { n: 'Frances Tiafoe', nat: 'American' }, { n: 'Alex de Minaur', nat: 'Australian' },
        { n: 'Elena Rybakina', nat: 'Kazakhstani' }, { n: 'Jessica Pegula', nat: 'American' }, { n: 'Ons Jabeur', nat: 'Tunisian' }, { n: 'Marketa Vondrousova', nat: 'Czech' }, { n: 'Qinwen Zheng', nat: 'Chinese' },
        { n: 'Maria Sakkari', nat: 'Greek' }, { n: 'Jelena Ostapenko', nat: 'Latvian' }, { n: 'Karolina Muchova', nat: 'Czech' }, { n: 'Barbora Krejcikova', nat: 'Czech' }, { n: 'Madison Keys', nat: 'American' },
        { n: 'Stan Wawrinka', nat: 'Swiss' }, { n: 'Andy Murray', nat: 'British' }, { n: 'Dominic Thiem', nat: 'Austrian' }, { n: 'Kei Nishikori', nat: 'Japanese' }, { n: 'Nick Kyrgios', nat: 'Australian' },
        { n: 'Felix Auger-Aliassime', nat: 'Canadian' }, { n: 'Lorenzo Musetti', nat: 'Italian' }, { n: 'Sebastian Korda', nat: 'American' }, { n: 'Arthur Fils', nat: 'French' }, { n: 'Jack Draper', nat: 'British' }
    ],
    'MotoGP': [
        { n: 'Marc Marquez', nat: 'Spanish' }, { n: 'Francesco Bagnaia', nat: 'Italian' }, { n: 'Fabio Quartararo', nat: 'French' }, { n: 'Jorge Martin', nat: 'Spanish' }, { n: 'Brad Binder', nat: 'South African' },
        { n: 'Marco Bezzecchi', nat: 'Italian' }, { n: 'Aleix Espargaro', nat: 'Spanish' }, { n: 'Maverick Vinales', nat: 'Spanish' }, { n: 'Enea Bastianini', nat: 'Italian' }, { n: 'Jack Miller', nat: 'Australian' },
        { n: 'Johann Zarco', nat: 'French' }, { n: 'Miguel Oliveira', nat: 'Portuguese' }, { n: 'Luca Marini', nat: 'Italian' }, { n: 'Alex Marquez', nat: 'Spanish' }, { n: 'Fabio Di Giannantonio', nat: 'Italian' },
        { n: 'Franco Morbidelli', nat: 'Italian' }, { n: 'Raul Fernandez', nat: 'Spanish' }, { n: 'Augusto Fernandez', nat: 'Spanish' }, { n: 'Takaaki Nakagami', nat: 'Japanese' }, { n: 'Joan Mir', nat: 'Spanish' },
        { n: 'Dani Pedrosa', nat: 'Spanish' }, { n: 'Casey Stoner', nat: 'Australian' }, { n: 'Valentino Rossi', nat: 'Italian' }, { n: 'Jorge Lorenzo', nat: 'Spanish' }, { n: 'Max Biaggi', nat: 'Italian' },
        { n: 'Mick Doohan', nat: 'Australian' }, { n: 'Kevin Schwantz', nat: 'American' }, { n: 'Wayne Rainey', nat: 'American' }, { n: 'Kenny Roberts', nat: 'American' }, { n: 'Giacomo Agostini', nat: 'Italian' },
        { n: 'Pedro Acosta', nat: 'Spanish' }, { n: 'Fermin Aldeguer', nat: 'Spanish' }, { n: 'Tony Arbolino', nat: 'Italian' }, { n: 'Jake Dixon', nat: 'British' }, { n: 'Ai Ogura', nat: 'Japanese' },
        { n: 'Celestino Vietti', nat: 'Italian' }, { n: 'Alonso Lopez', nat: 'Spanish' }, { n: 'Somkiat Chantra', nat: 'Thai' }, { n: 'Barry Baltus', nat: 'Belgian' }, { n: 'Izan Guevara', nat: 'Spanish' }
    ],
    'Hockey': [
        { n: 'Manpreet Singh', nat: 'Indian' }, { n: 'PR Sreejesh', nat: 'Indian' }, { n: 'Harmanpreet Singh', nat: 'Indian' }, { n: 'Arthur Van Doren', nat: 'Belgian' }, { n: 'Alexander Hendrickx', nat: 'Belgian' },
        { n: 'Thierry Brinkman', nat: 'Dutch' }, { n: 'Pirmin Blaak', nat: 'Dutch' }, { n: 'Eddie Ockenden', nat: 'Australian' }, { n: 'Blake Govers', nat: 'Australian' }, { n: 'Zach Wallace', nat: 'British' },
        { n: 'Pau Quemada', nat: 'Spanish' }, { n: 'Tom Boon', nat: 'Belgian' }, { n: 'Jip Janssen', nat: 'Dutch' }, { n: 'Christopher Ruhr', nat: 'German' }, { n: 'Niklas Wellen', nat: 'German' },
        { n: 'Mandeep Singh', nat: 'Indian' }, { n: 'Amit Rohidas', nat: 'Indian' }, { n: 'Hardik Singh', nat: 'Indian' }, { n: 'Vivek Sagar Prasad', nat: 'Indian' }, { n: 'Sumit Walmiki', nat: 'Indian' },
        { n: 'Victor Wegnez', nat: 'Belgian' }, { n: 'Florent van Aubel', nat: 'Belgian' }, { n: 'Vincent Vanasch', nat: 'Belgian' }, { n: 'Aran Zalewski', nat: 'Australian' }, { n: 'Jeremy Hayward', nat: 'Australian' },
        { n: 'Andrew Charter', nat: 'Australian' }, { n: 'Xan de Waard', nat: 'Dutch' }, { n: 'Lidewij Welten', nat: 'Dutch' }, { n: 'Eva de Goede', nat: 'Dutch' }, { n: 'Maria Verschoor', nat: 'Dutch' },
        { n: 'Savita Punia', nat: 'Indian' }, { n: 'Vandana Katariya', nat: 'Indian' }, { n: 'Rani Rampal', nat: 'Indian' }, { n: 'Navneet Kaur', nat: 'Indian' }, { n: 'Deep Grace Ekka', nat: 'Indian' },
        { n: 'Gurjit Kaur', nat: 'Indian' }, { n: 'Stacey Michelsen', nat: 'New Zealander' }, { n: 'Delfina Merino', nat: 'Argentinian' }, { n: 'Agustina Albertarrio', nat: 'Argentinian' }, { n: 'Luciana Aymar', nat: 'Argentinian' }
    ],
    'Swimming': [
        { n: 'Michael Phelps', nat: 'American' }, { n: 'Katie Ledecky', nat: 'American' }, { n: 'Caeleb Dressel', nat: 'American' }, { n: 'Adam Peaty', nat: 'British' }, { n: 'Ariarne Titmus', nat: 'Australian' },
        { n: 'Kaylee McKeown', nat: 'Australian' }, { n: 'Emma McKeon', nat: 'Australian' }, { n: 'Kyle Chalmers', nat: 'Australian' }, { n: 'Kristof Milak', nat: 'Hungarian' }, { n: 'Leon Marchand', nat: 'French' },
        { n: 'David Popovici', nat: 'Romanian' }, { n: 'Zhanle Pan', nat: 'Chinese' }, { n: 'Qin Haiyang', nat: 'Chinese' }, { n: 'Zhang Yufei', nat: 'Chinese' }, { n: 'Sarah Sjostrom', nat: 'Swedish' },
        { n: 'Katinka Hosszu', nat: 'Hungarian' }, { n: 'Ranomi Kromowidjojo', nat: 'Dutch' }, { n: 'Lilly King', nat: 'American' }, { n: 'Ryan Murphy', description: 'American' }, { n: 'Bobby Finke', nat: 'American' },
        { n: 'Summer McIntosh', nat: 'Canadian' }, { n: 'Penny Oleksiak', nat: 'Canadian' }, { n: 'Maggie Mac Neil', nat: 'Canadian' }, { n: 'Josh Liendo', nat: 'Canadian' }, { n: 'Tatjana Smith', nat: 'South African' },
        { n: 'Chad le Clos', nat: 'South African' }, { n: 'Cameron van der Burgh', nat: 'South African' }, { n: 'Mireia Belmonte', nat: 'Spanish' }, { n: 'Federica Pellegrini', nat: 'Italian' }, { n: 'Thomas Ceccon', nat: 'Italian' },
        { n: 'Gregorio Paltrinieri', nat: 'Italian' }, { n: 'Siobhan Haughey', nat: 'Hong Konger' }, { n: 'Rikako Ikee', nat: 'Japanese' }, { n: 'Daiya Seto', nat: 'Japanese' }, { n: 'Kosuke Hagino', nat: 'Japanese' },
        { n: 'Ian Thorpe', nat: 'Australian' }, { n: 'Grant Hackett', nat: 'Australian' }, { n: 'Dawn Fraser', nat: 'Australian' }, { n: 'Shane Gould', nat: 'Australian' }, { n: 'Mark Spitz', nat: 'American' }
    ]
};

const migrate = async () => {
    try {
        console.log('Starting Universal Legend Migration (Hockey & Swimming Included)...');
        
        await pool.query("SET FOREIGN_KEY_CHECKS = 0");
        const tables = ['SELECTION', 'FITNESS_RECORD', 'STATS_CRICKET', 'STATS_FOOTBALL', 'STATS_BADMINTON', 'STATS_TENNIS', 'STATS_BASKETBALL', 'STATS_F1', 'STATS_MOTOGP', 'STATS_HOCKEY', 'STATS_SWIMMING', 'PLAYER', 'TEAM'];
        for (let t of tables) await pool.query(`TRUNCATE TABLE ${t}`);
        await pool.query("SET FOREIGN_KEY_CHECKS = 1");

        const [sports] = await pool.query("SELECT * FROM SPORT");
        
        for (let s of sports) {
            console.log(`Injecting Global Icons for ${s.sport_name}...`);
            const athletes = LEGENDS_DATA[s.sport_name] || [];
            
            const teams = [`${s.sport_name} Elite`, `${s.sport_name} National`, `${s.sport_name} Global`, `${s.sport_name} Franchise`];
            for (let tName of teams) {
                await pool.query("INSERT INTO TEAM (sport_id, team_name) VALUES (?, ?)", [s.sport_id, tName]);
            }
            const [tRows] = await pool.query("SELECT team_id FROM TEAM WHERE sport_id = ?", [s.sport_id]);

            for (let i = 0; i < athletes.length; i++) {
                const a = athletes[i];
                const teamId = tRows[i % tRows.length].team_id;
                
                const [res] = await pool.query("INSERT INTO PLAYER (name, age, team_id, nationality, height, weight, bio) VALUES (?, ?, ?, ?, ?, ?, ?)", 
                    [a.n, 20 + Math.floor(Math.random() * 15), teamId, a.nat || 'Global', 170 + Math.floor(Math.random() * 30), 60 + Math.floor(Math.random() * 40), 
                    `Elite ${s.sport_name} legend with a global reputation for tactical excellence and high-impact performance.`]);
                
                await pool.query("INSERT INTO FITNESS_RECORD (player_id, stamina_score, speed_score, injury_status, test_date) VALUES (?, ?, ?, ?, ?)",
                    [res.insertId, 85 + Math.floor(Math.random() * 15), 80 + Math.floor(Math.random() * 20), false, '2024-05-01']);
            }
        }

        console.log('Universal Migration Complete. 440+ Athletes corrected.');
        process.exit(0);
    } catch (err) {
        console.error('Migration failed:', err);
        process.exit(1);
    }
};

migrate();
