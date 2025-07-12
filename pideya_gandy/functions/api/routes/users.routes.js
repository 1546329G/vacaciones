// C:\fluter-proyect\vacaciones\my_first_app\functions\api\routes\users.routes.js
import { Router } from 'express';
import * as usersController from '../controllers/users.controller.js';
import { authenticateToken } from '../middleware/authMiddleware.js'; // ¡Importa el middleware de autenticación!

const router = Router();

// Rutas de gestión del propio perfil del usuario (estas requieren autenticación)
router.get('/me', authenticateToken, usersController.getOwnProfile);
router.put('/me', authenticateToken, usersController.updateOwnProfile);

// Rutas para la gestión de direcciones de usuario (también requieren autenticación)
router.post('/me/addresses', authenticateToken, usersController.addAddress);
router.get('/me/addresses', authenticateToken, usersController.getAddresses);
router.put('/me/addresses/:addressId', authenticateToken, usersController.updateAddress);
router.delete('/me/addresses/:addressId', authenticateToken, usersController.deleteAddress);

export default router;