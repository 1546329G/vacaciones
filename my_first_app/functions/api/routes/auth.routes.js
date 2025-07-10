// C:\fluter-proyect\vacaciones\my_first_app\functions\api\routes\auth.routes.js
import { Router } from 'express';
import * as authController from '../controllers/auth.controller.js';

const router = Router();

// Rutas de autenticación
router.post('/register', authController.crearUsuario);
router.post('/login', authController.loginUsuario);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);

export default router;