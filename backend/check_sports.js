const mysql = require('mysql2/promise');
const pool = mysql.createPool({ host: 'localhost', user: 'sports_admin', password: 'sports123', database: 'multi_sport_selection' });
async function check() {
    const [rows] = await pool.query("SELECT * FROM SPORT");
    console.log(JSON.stringify(rows, null, 2));
    process.exit(0);
}
check();
