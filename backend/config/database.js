const { Sequelize } = require('sequelize');

console.log('🧩 Chargement config Sequelize :', {
  db: process.env.DB_NAME,
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT
});

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD || null,
  {
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT),
    dialect: 'postgres',
    logging: false,
    dialectOptions: {
      application_name: 'mosquee_backend'
    }
  }
);

module.exports = sequelize;
