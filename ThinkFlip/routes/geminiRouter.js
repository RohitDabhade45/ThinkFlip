import ensureAuthenticated from '../middlewares/auth.js';
import express from 'express';
import {aiController} from '../controllers/aiController.js';
import {mcqController} from '../controllers/mcqController.js';

const router = express.Router();

// router.post("/", ensureAuthenticated,aiController);
router.post("/",aiController);
router.post("/mcq",mcqController);


export default router;
