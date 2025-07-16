import express from "express";
import { saveDocumentWithHistory,getUserHistory,deleteScannedDocument } from "../controllers/historyController.js";
import ensureAuthenticated from "../middlewares/auth.js";

const router = express.Router();

router.post("/save-document",ensureAuthenticated, saveDocumentWithHistory);
router.get("/user-history",ensureAuthenticated, getUserHistory);
router.delete("/delete-document/:id",ensureAuthenticated, deleteScannedDocument);

export default router;
