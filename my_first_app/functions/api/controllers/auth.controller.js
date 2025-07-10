// C:\fluter-proyect\vacaciones\my_first_app\functions\api\controllers\auth.controller.js
import mysql from 'mysql2/promise';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken'; // Importar jsonwebtoken
import { v4 as uuidv4 } from 'uuid'; // Para generar tokens de reseteo únicos
import { sendPasswordResetEmail } from '../utils/emailService.js'; // Necesitaremos crear este servicio

// Asegúrate de que esta variable de entorno esté definida en tu archivo .env
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key'; // ¡CAMBIA ESTO EN PRODUCCIÓN!
const JWT_EXPIRES_IN = '1h'; // El token expirará en 1 hora

// Función para crear un nuevo usuario (Registro)
export const crearUsuario = async (req, res) => {
    console.log("auth.controller - crearUsuario: Solicitud recibida.");
    const { email, password, rol } = req.body;
    console.log("auth.controller - crearUsuario: Campos recibidos:", { email, password: password ? '[REDACTED]' : 'N/A', rol });

    if (!email || !password || !rol) {
        console.log("auth.controller - crearUsuario: Error 400 - Faltan campos obligatorios.");
        return res.status(400).json({ error: "Faltan campos obligatorios: email, password y rol" });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        console.log(`auth.controller - crearUsuario: Error 400 - Formato de email inválido: ${email}`);
        return res.status(400).json({ error: "Formato de email inválido" });
    }
    if (!['cliente', 'repartidor', 'establecimiento'].includes(rol)) {
        console.log(`auth.controller - crearUsuario: Error 400 - Rol inválido: ${rol}`);
        return res.status(400).json({ error: "Rol inválido" });
    }

    let hashedPassword;
    try {
        console.log("auth.controller - crearUsuario: Hashing de la contraseña...");
        hashedPassword = await bcrypt.hash(password, 10);
        console.log("auth.controller - crearUsuario: Contraseña hasheada.");
    } catch (hashError) {
        console.error("auth.controller - crearUsuario: Error al hashear la contraseña:", hashError);
        return res.status(500).json({ error: "Error interno al procesar contraseña", details: hashError.message });
    }

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);
        console.log("auth.controller - crearUsuario: Conexión exitosa a la DB.");
        const [result] = await connection.execute(
            'INSERT INTO usuarios (email, password_hash, rol) VALUES (?, ?, ?)',
            [email, hashedPassword, rol]
        );
        const userId = result.insertId;
        console.log(`auth.controller - crearUsuario: Inserción exitosa. ID: ${userId}`);

        // Generar JWT
        const token = jwt.sign({ id: userId, email: email, rol: rol }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

        res.status(201).json({
            message: 'Usuario registrado exitosamente!',
            token: token,
            user: {
                id: userId,
                email: email,
                rol: rol,
            },
        });
    } catch (error) {
        console.error("auth.controller - crearUsuario: Error en DB:", error);
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ error: 'El email ya está registrado en la base de datos.', details: error.message });
        }
        res.status(500).json({ error: 'Error interno del servidor al registrar usuario', details: error.message });
    } finally {
        if (connection) await connection.end();
        console.log("auth.controller - crearUsuario: Conexión a la DB cerrada.");
    }
};

// Función para iniciar sesión (Login)
export const loginUsuario = async (req, res) => {
    console.log("auth.controller - loginUsuario: Solicitud recibida.");
    const { email, password } = req.body;
    console.log("auth.controller - loginUsuario: Campos recibidos:", { email, password: password ? '[REDACTED]' : 'N/A' });

    if (!email || !password) {
        console.log("auth.controller - loginUsuario: Error 400 - Faltan campos obligatorios.");
        return res.status(400).json({ error: "Faltan campos obligatorios: email y password" });
    }

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);
        console.log("auth.controller - loginUsuario: Conexión exitosa a la DB.");
        const [rows] = await connection.execute(
            'SELECT id_usuario, email, password_hash, rol, activo FROM usuarios WHERE email = ?',
            [email]
        );

        if (rows.length === 0) {
            console.log("auth.controller - loginUsuario: Usuario no encontrado.");
            return res.status(401).json({ error: "Credenciales inválidas" });
        }

        const user = rows[0];
        const isPasswordValid = await bcrypt.compare(password, user.password_hash);

        if (!isPasswordValid) {
            console.log("auth.controller - loginUsuario: Contraseña inválida.");
            return res.status(401).json({ error: "Credenciales inválidas" });
        }

        if (!user.activo) {
            console.log("auth.controller - loginUsuario: Usuario inactivo.");
            return res.status(403).json({ error: "Usuario inactivo" });
        }

        // Generar JWT
        const token = jwt.sign({ id: user.id_usuario, email: user.email, rol: user.rol }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });

        console.log("auth.controller - loginUsuario: Autenticación exitosa.");
        res.status(200).json({
            message: "Inicio de sesión exitoso",
            token: token,
            user: {
                id: user.id_usuario,
                email: user.email,
                rol: user.rol,
                activo: user.activo,
            },
        });
    } catch (error) {
        console.error("auth.controller - loginUsuario: Error en DB:", error);
        res.status(500).json({ error: "Error interno del servidor al iniciar sesión", details: error.message });
    } finally {
        if (connection) await connection.end();
        console.log("auth.controller - loginUsuario: Conexión a la DB cerrada.");
    }
};

// Función para solicitar restablecimiento de contraseña (Forgot Password)
export const forgotPassword = async (req, res) => {
    console.log("auth.controller - forgotPassword: Solicitud recibida.");
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ error: "El email es obligatorio." });
    }

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);
        const [rows] = await connection.execute('SELECT id_usuario FROM usuarios WHERE email = ?', [email]);

        if (rows.length === 0) {
            // Para seguridad, no confirmamos si el email existe o no
            console.log(`auth.controller - forgotPassword: Intento de reseteo para email no encontrado: ${email}`);
            return res.status(200).json({ message: "Si el email está registrado, recibirás un enlace para restablecer tu contraseña." });
        }

        const userId = rows[0].id_usuario;
        const resetToken = uuidv4(); // Genera un token único
        const expiresAt = new Date(Date.now() + 3600000); // Token válido por 1 hora

        await connection.execute(
            'UPDATE usuarios SET reset_password_token = ?, reset_password_expires = ? WHERE id_usuario = ?',
            [resetToken, expiresAt, userId]
        );

        // Envía el email con el enlace de reseteo
        // La URL completa dependerá de cómo configures tu frontend para el reseteo
        const resetUrl = `http://yourfrontend.com/reset-password?token=${resetToken}`;
        await sendPasswordResetEmail(email, resetUrl); // Esta función debe ser implementada

        console.log(`auth.controller - forgotPassword: Enlace de reseteo enviado a ${email}`);
        res.status(200).json({ message: "Si el email está registrado, recibirás un enlace para restablecer tu contraseña." });

    } catch (error) {
        console.error("auth.controller - forgotPassword: Error:", error);
        res.status(500).json({ error: "Error interno del servidor al solicitar reseteo de contraseña", details: error.message });
    } finally {
        if (connection) await connection.end();
    }
};

// Función para restablecer contraseña (Reset Password)
export const resetPassword = async (req, res) => {
    console.log("auth.controller - resetPassword: Solicitud recibida.");
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
        return res.status(400).json({ error: "Token y nueva contraseña son obligatorios." });
    }

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);
        const [rows] = await connection.execute(
            'SELECT id_usuario FROM usuarios WHERE reset_password_token = ? AND reset_password_expires > NOW()',
            [token]
        );

        if (rows.length === 0) {
            console.log(`auth.controller - resetPassword: Token inválido o expirado.`);
            return res.status(400).json({ error: "Token de restablecimiento inválido o ha expirado." });
        }

        const userId = rows[0].id_usuario;
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        await connection.execute(
            'UPDATE usuarios SET password_hash = ?, reset_password_token = NULL, reset_password_expires = NULL WHERE id_usuario = ?',
            [hashedPassword, userId]
        );

        console.log(`auth.controller - resetPassword: Contraseña restablecida exitosamente para usuario ${userId}`);
        res.status(200).json({ message: "Contraseña restablecida exitosamente." });

    } catch (error) {
        console.error("auth.controller - resetPassword: Error:", error);
        res.status(500).json({ error: "Error interno del servidor al restablecer contraseña", details: error.message });
    } finally {
        if (connection) await connection.end();
    }
};