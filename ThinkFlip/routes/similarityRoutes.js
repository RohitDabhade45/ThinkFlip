import express from 'express';
import { textSimilarityNinja, textSimilarityNlpCloud } from '../controllers/similarityControler.js';

const router = express.Router();

router.post('/semantic-similarity-ninja', textSimilarityNinja);
router.post('/semantic-similarity-nlpcloud', textSimilarityNlpCloud);

export default router;
