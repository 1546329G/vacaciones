const functions = require("firebase-functions");
const mysql = require("mysql2/promise");

// =====================================================================
// Adaptación para el Emulador Local con Node.js 20
// (Igual que antes, para que funcione con el .env en desarrollo local)
// =====================================================================

// La configuración de la base de datos ahora se construye dentro de cada función
// para asegurar que las variables de entorno se lean correctamente en el contexto.

// Función de ejemplo: 'getDatos' (la que ya tienes)
exports.getDatos = functions.https.onRequest(
  {}, // No se necesita 'secrets' aquí para el emulador local
  async (request, response) => {
    response.set("Access-Control-Allow-Origin", "*");

    if (request.method === "OPTIONS") {
      console.log("getDatos: Recibida solicitud OPTIONS (CORS preflight).");
      response.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
      response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
      response.status(204).send("");
      return;
    }

    const dbConfig = {
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: 3306,
    };
    console.log("getDatos: Configuración de DB cargada.");

    let connection;
    try {
      console.log("getDatos: Intentando conectar a la base de datos...");
      connection = await mysql.createConnection(dbConfig);
      console.log("getDatos: Conexión exitosa a la base de datos.");

      console.log("getDatos: Ejecutando consulta SELECT...");
      const [rows, _] = await connection.execute("SELECT * FROM usuarios LIMIT 10"); // Cambiado a 'usuarios'
      console.log(`getDatos: Consulta SELECT exitosa. Filas obtenidas: ${rows.length}`);

      response.status(200).json({
        message: "Datos obtenidos exitosamente de Hostinger!",
        data: rows,
      });
      console.log("getDatos: Respuesta 200 enviada con datos.");

    } catch (error) {
      console.error(
        "Error al conectar o consultar la base de datos (getDatos):",
        error
      );
      response.status(500).json({
        error: "Error interno del servidor al obtener datos",
        details: error.message,
      });
      console.log("getDatos: Respuesta 500 enviada debido a un error.");

    } finally {
      if (connection) {
        await connection.end();
        console.log("getDatos: Conexión a la base de datos cerrada.");
      }
    }
  }
);

// Nueva función: 'crearUsuario'
// Esta función recibirá datos por POST para insertar un nuevo usuario.
exports.crearUsuario = functions.https.onRequest(
  {}, // No se necesita 'secrets' aquí para el emulador local
  async (request, response) => {
    console.log("crearUsuario: Solicitud recibida.");
    response.set("Access-Control-Allow-Origin", "*");
    response.set("Access-Control-Allow-Headers", "Content-Type"); // Permitir Content-Type para POST

    if (request.method === "OPTIONS") {
      console.log("crearUsuario: Recibida solicitud OPTIONS (CORS preflight).");
      response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
      response.set("Access-Control-Allow-Headers", "Content-Type");
      response.status(204).send("");
      return;
    }

    if (request.method !== "POST") {
      console.log(`crearUsuario: Método no permitido: ${request.method}. Se esperaba POST.`);
      response.status(405).json({ error: "Solo se permiten solicitudes POST" });
      return;
    }

    // Asegúrate de que el cuerpo de la petición sea JSON y tenga los campos esperados
    const { email, password, rol } = request.body;
    console.log("crearUsuario: Campos recibidos del body:", { email, password: password ? '[REDACTED]' : 'N/A', rol });

    // Validaciones básicas de entrada
    if (!email || !password || !rol) {
      console.log("crearUsuario: Error 400 - Faltan campos obligatorios.");
      response.status(400).json({ error: "Faltan campos obligatorios: email, password y rol" });
      return;
    }

    // Validación de formato de email (simple)
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      console.log(`crearUsuario: Error 400 - Formato de email inválido: ${email}`);
      response.status(400).json({ error: "Formato de email inválido" });
      return;
    }

    const dbConfig = {
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: 3306,
    };
    console.log("crearUsuario: Configuración de DB cargada.");
    console.log(`crearUsuario: Conectando a DB: ${dbConfig.host}/${dbConfig.database} con usuario ${dbConfig.user}`);


    let connection;
    try {
      console.log("crearUsuario: Intentando conectar a la base de datos...");
      connection = await mysql.createConnection(dbConfig);
      console.log("crearUsuario: Conexión exitosa a la base de datos.");

      console.log(`crearUsuario: Ejecutando consulta INSERT para email: ${email}, rol: ${rol}`);
      const [result] = await connection.execute(
        'INSERT INTO usuarios (email, rol) VALUES (?, ?)',
        [email, rol]
      );
      console.log(`crearUsuario: Inserción exitosa. ID del nuevo usuario: ${result.insertId}`);

      response.status(201).json({
        message: 'Usuario registrado exitosamente en Hostinger!',
        id_usuario: result.insertId,
        email: email,
        rol: rol,
      });
      console.log("crearUsuario: Respuesta 201 (Created) enviada.");

    } catch (error) {
      console.error("crearUsuario: Error en el bloque try-catch:", error);
      // Puedes añadir manejo de errores específicos, como email duplicado (ER_DUP_ENTRY)
      if (error.code === 'ER_DUP_ENTRY') {
        console.log("crearUsuario: Error 409 - Email ya registrado (ER_DUP_ENTRY).");
        response.status(409).json({
          error: 'El email ya está registrado en la base de datos.',
          details: error.message,
        });
      } else {
        console.log(`crearUsuario: Error 500 - Otro error interno: ${error.message}`);
        response.status(500).json({
          error: 'Error interno del servidor al registrar usuario en Hostinger',
          details: error.message,
        });
      }
    } finally {
      if (connection) {
        await connection.end();
        console.log("crearUsuario: Conexión a la base de datos cerrada.");
      }
    }
  }
);