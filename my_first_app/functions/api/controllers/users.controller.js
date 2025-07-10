// C:\fluter-proyect\vacaciones\my_first_app\functions\api\controllers\users.controller.js
import mysql from 'mysql2/promise';

// Obtener el propio perfil del usuario (EXISTENTE)
export const getOwnProfile = async (req, res) => {
    console.log("users.controller - getOwnProfile: Solicitud recibida.");
    const userId = req.user.id;
    console.log(`users.controller - getOwnProfile: Obteniendo perfil para userId: ${userId}`);

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);
        const [rows] = await connection.execute(
            'SELECT id_usuario, email, rol, nombre, telefono, activo, created_at, updated_at FROM usuarios WHERE id_usuario = ?',
            [userId]
        );

        if (rows.length === 0) {
            console.log(`users.controller - getOwnProfile: Usuario ${userId} no encontrado.`);
            return res.status(404).json({ error: "Perfil de usuario no encontrado." });
        }

        console.log(`users.controller - getOwnProfile: Perfil de usuario ${userId} obtenido exitosamente.`);
        res.status(200).json({
            message: "Perfil de usuario obtenido exitosamente.",
            user: rows[0]
        });

    } catch (error) {
        console.error("users.controller - getOwnProfile: Error al obtener perfil:", error);
        res.status(500).json({ error: "Error interno del servidor al obtener perfil de usuario", details: error.message });
    } finally {
        if (connection) await connection.end();
        console.log("users.controller - getOwnProfile: Conexión a la DB cerrada.");
    }
};

// Actualizar el propio perfil del usuario (EXISTENTE)
export const updateOwnProfile = async (req, res) => {
    console.log("users.controller - updateOwnProfile: Solicitud recibida.");
    const userId = req.user.id;
    const { nombre, telefono } = req.body;
    console.log(`users.controller - updateOwnProfile: Actualizando perfil para userId: ${userId} con datos:`, req.body);

    if (!nombre && !telefono) {
        return res.status(400).json({ error: "No se proporcionaron datos para actualizar el perfil." });
    }

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);
        const updateFields = [];
        const updateValues = [];

        if (nombre !== undefined) {
            updateFields.push('nombre = ?');
            updateValues.push(nombre);
        }
        if (telefono !== undefined) {
            updateFields.push('telefono = ?');
            updateValues.push(telefono);
        }

        if (updateFields.length === 0) {
            return res.status(400).json({ error: "No hay campos válidos para actualizar." });
        }

        updateValues.push(userId); // Añade el ID del usuario al final para la cláusula WHERE

        const query = `UPDATE usuarios SET ${updateFields.join(', ')}, updated_at = NOW() WHERE id_usuario = ?`;
        const [result] = await connection.execute(query, updateValues);

        if (result.affectedRows === 0) {
            console.log(`users.controller - updateOwnProfile: Usuario ${userId} no encontrado para actualizar.`);
            return res.status(404).json({ error: "Perfil de usuario no encontrado o no se pudo actualizar." });
        }

        const [updatedRows] = await connection.execute(
            'SELECT id_usuario, email, rol, nombre, telefono, activo, created_at, updated_at FROM usuarios WHERE id_usuario = ?',
            [userId]
        );

        console.log(`users.controller - updateOwnProfile: Perfil de usuario ${userId} actualizado exitosamente.`);
        res.status(200).json({
            message: "Perfil de usuario actualizado exitosamente.",
            user: updatedRows[0]
        });

    } catch (error) {
        console.error("users.controller - updateOwnProfile: Error al actualizar perfil:", error);
        res.status(500).json({ error: "Error interno del servidor al actualizar perfil de usuario", details: error.message });
    } finally {
        if (connection) await connection.end();
        console.log("users.controller - updateOwnProfile: Conexión a la DB cerrada.");
    }
};

// ==========================================================
// NUEVAS FUNCIONES PARA GESTIÓN DE DIRECCIONES DE USUARIO
// ==========================================================

// Añadir una nueva dirección
export const addAddress = async (req, res) => {
    console.log("users.controller - addAddress: Solicitud recibida.");
    const userId = req.user.id;
    const { alias, calle, numero, referencia, distrito, ciudad, codigo_postal, latitud, longitud, is_default } = req.body;
    console.log(`users.controller - addAddress: Añadiendo dirección para userId: ${userId} con alias: ${alias}`);

    if (!alias || !calle || !ciudad) { // Campos mínimos obligatorios
        return res.status(400).json({ error: "Faltan campos obligatorios para la dirección: alias, calle, ciudad." });
    }

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);

        // Si se marca como default, desmarcar otras direcciones default del mismo usuario
        if (is_default) {
            await connection.execute(
                'UPDATE direcciones_usuario SET is_default = FALSE WHERE id_usuario = ? AND is_default = TRUE',
                [userId]
            );
        }

        const [result] = await connection.execute(
            `INSERT INTO direcciones_usuario (id_usuario, alias, calle, numero, referencia, distrito, ciudad, codigo_postal, latitud, longitud, is_default)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [userId, alias, calle, numero, referencia, distrito, ciudad, codigo_postal, latitud, longitud, is_default || false]
        );

        console.log(`users.controller - addAddress: Dirección añadida exitosamente para userId: ${userId}, ID: ${result.insertId}`);
        res.status(201).json({
            message: "Dirección añadida exitosamente.",
            id_direccion: result.insertId,
            alias: alias
        });

    } catch (error) {
        console.error("users.controller - addAddress: Error al añadir dirección:", error);
        res.status(500).json({ error: "Error interno del servidor al añadir dirección", details: error.message });
    } finally {
        if (connection) await connection.end();
        console.log("users.controller - addAddress: Conexión a la DB cerrada.");
    }
};

// Obtener todas las direcciones del usuario
export const getAddresses = async (req, res) => {
    console.log("users.controller - getAddresses: Solicitud recibida.");
    const userId = req.user.id;
    console.log(`users.controller - getAddresses: Obteniendo direcciones para userId: ${userId}`);

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);
        const [rows] = await connection.execute(
            'SELECT * FROM direcciones_usuario WHERE id_usuario = ? ORDER BY is_default DESC, alias ASC',
            [userId]
        );

        console.log(`users.controller - getAddresses: ${rows.length} direcciones obtenidas para userId: ${userId}`);
        res.status(200).json({
            message: "Direcciones obtenidas exitosamente.",
            addresses: rows
        });

    } catch (error) {
        console.error("users.controller - getAddresses: Error al obtener direcciones:", error);
        res.status(500).json({ error: "Error interno del servidor al obtener direcciones", details: error.message });
    } finally {
        if (connection) await connection.end();
        console.log("users.controller - getAddresses: Conexión a la DB cerrada.");
    }
};

// Actualizar una dirección existente
export const updateAddress = async (req, res) => {
    console.log("users.controller - updateAddress: Solicitud recibida.");
    const userId = req.user.id;
    const { addressId } = req.params; // Viene de la URL /users/me/addresses/:addressId
    const { alias, calle, numero, referencia, distrito, ciudad, codigo_postal, latitud, longitud, is_default } = req.body;
    console.log(`users.controller - updateAddress: Actualizando dirección ${addressId} para userId: ${userId}`);

    if (!alias && !calle && !numero && !referencia && !distrito && !ciudad && !codigo_postal && latitud === undefined && longitud === undefined && is_default === undefined) {
        return res.status(400).json({ error: "No se proporcionaron datos para actualizar la dirección." });
    }

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);

        // Primero, verifica que la dirección pertenezca al usuario
        const [checkRows] = await connection.execute(
            'SELECT id_usuario FROM direcciones_usuario WHERE id_direccion = ?',
            [addressId]
        );
        if (checkRows.length === 0 || checkRows[0].id_usuario !== userId) {
            console.log(`users.controller - updateAddress: Intento de actualizar dirección no autorizada o no encontrada. UserId: ${userId}, AddressId: ${addressId}`);
            return res.status(403).json({ error: "No tienes permiso para actualizar esta dirección o no existe." });
        }

        // Si se marca como default, desmarcar otras direcciones default del mismo usuario
        if (is_default === true) {
            await connection.execute(
                'UPDATE direcciones_usuario SET is_default = FALSE WHERE id_usuario = ? AND is_default = TRUE AND id_direccion != ?',
                [userId, addressId]
            );
        }

        const updateFields = [];
        const updateValues = [];

        if (alias !== undefined) { updateFields.push('alias = ?'); updateValues.push(alias); }
        if (calle !== undefined) { updateFields.push('calle = ?'); updateValues.push(calle); }
        if (numero !== undefined) { updateFields.push('numero = ?'); updateValues.push(numero); }
        if (referencia !== undefined) { updateFields.push('referencia = ?'); updateValues.push(referencia); }
        if (distrito !== undefined) { updateFields.push('distrito = ?'); updateValues.push(distrito); }
        if (ciudad !== undefined) { updateFields.push('ciudad = ?'); updateValues.push(ciudad); }
        if (codigo_postal !== undefined) { updateFields.push('codigo_postal = ?'); updateValues.push(codigo_postal); }
        if (latitud !== undefined) { updateFields.push('latitud = ?'); updateValues.push(latitud); }
        if (longitud !== undefined) { updateFields.push('longitud = ?'); updateValues.push(longitud); }
        if (is_default !== undefined) { updateFields.push('is_default = ?'); updateValues.push(is_default); }

        if (updateFields.length === 0) {
            return res.status(400).json({ error: "No hay campos válidos para actualizar." });
        }

        updateValues.push(addressId); // Para la cláusula WHERE
        updateValues.push(userId);    // Para la cláusula WHERE

        const query = `UPDATE direcciones_usuario SET ${updateFields.join(', ')}, updated_at = NOW() WHERE id_direccion = ? AND id_usuario = ?`;
        const [result] = await connection.execute(query, updateValues);

        if (result.affectedRows === 0) {
            console.log(`users.controller - updateAddress: Dirección ${addressId} para userId ${userId} no encontrada o sin cambios.`);
            return res.status(404).json({ error: "Dirección no encontrada o no se pudo actualizar." });
        }

        console.log(`users.controller - updateAddress: Dirección ${addressId} actualizada exitosamente.`);
        res.status(200).json({ message: "Dirección actualizada exitosamente." });

    } catch (error) {
        console.error("users.controller - updateAddress: Error al actualizar dirección:", error);
        res.status(500).json({ error: "Error interno del servidor al actualizar dirección", details: error.message });
    } finally {
        if (connection) await connection.end();
        console.log("users.controller - updateAddress: Conexión a la DB cerrada.");
    }
};

// Eliminar una dirección
export const deleteAddress = async (req, res) => {
    console.log("users.controller - deleteAddress: Solicitud recibida.");
    const userId = req.user.id;
    const { addressId } = req.params; // Viene de la URL /users/me/addresses/:addressId
    console.log(`users.controller - deleteAddress: Eliminando dirección ${addressId} para userId: ${userId}`);

    let connection;
    try {
        connection = await mysql.createConnection(req.dbConfig);

        // Verifica que la dirección pertenezca al usuario antes de eliminar
        const [result] = await connection.execute(
            'DELETE FROM direcciones_usuario WHERE id_direccion = ? AND id_usuario = ?',
            [addressId, userId]
        );

        if (result.affectedRows === 0) {
            console.log(`users.controller - deleteAddress: Dirección ${addressId} para userId ${userId} no encontrada o no se pudo eliminar.`);
            return res.status(404).json({ error: "Dirección no encontrada o no se pudo eliminar." });
        }

        console.log(`users.controller - deleteAddress: Dirección ${addressId} eliminada exitosamente.`);
        res.status(200).json({ message: "Dirección eliminada exitosamente." });

    } catch (error) {
        console.error("users.controller - deleteAddress: Error al eliminar dirección:", error);
        res.status(500).json({ error: "Error interno del servidor al eliminar dirección", details: error.message });
    } finally {
        if (connection) await connection.end();
        console.log("users.controller - deleteAddress: Conexión a la DB cerrada.");
    }
};