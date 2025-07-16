import ScannedDocModel from "../models/scannedDocs.js";
import UserModel from "../models/user.js";

export const saveDocumentWithHistory = async (req, res) => {
  const userId = req.user._id;
  const content = req.body.content;

  try {
    const scannedDoc = new ScannedDocModel({ user: userId, content });
    await scannedDoc.save();
    await UserModel.findByIdAndUpdate(
      userId,
      { $push: { history: scannedDoc._id } },
      { new: true }
    );
    res.status(201).json({
      message: "Document saved and history updated",
      scannedDoc,
    });
  } catch (err) {
    console.error("Error saving document and updating history:", err);
    res.status(500).json({ error: "Failed to save document and update history" });
  }
};

export const getUserHistory = async (req, res) => {
  const userId = req.user._id;

  try {
    // Find user and populate history with ScannedDocs details
    const user = await UserModel.findById(userId).populate("history");

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.status(200).json({ history: user.history });
  } catch (err) {
    console.error("Error fetching user history:", err);
    res.status(500).json({ error: "Failed to fetch user history" });
  }
};



export const deleteScannedDocument = async (req, res) => {
  const userId = req.user._id; // Authenticated user ID
  const documentId = req.params.id; // Document ID from the request URL

  try {
    // Check if the document exists
    const document = await ScannedDocModel.findById(documentId);
    if (!document) {
      return res.status(404).json({ error: "Document not found" });
    }

    // Ensure the user owns the document before deleting
    if (document.user.toString() !== userId.toString()) {
      return res.status(403).json({ error: "Unauthorized: You don't own this document" });
    }

    // 1️⃣ Delete the scanned document
    await ScannedDocModel.findByIdAndDelete(documentId);

    // 2️⃣ Remove the document ID from the user's history
    await UserModel.findByIdAndUpdate(
      userId,
      { $pull: { history: documentId } }, // Remove the ID from history array
      { new: true }
    );

    res.status(200).json({ message: "Document deleted successfully" });
  } catch (err) {
    console.error("Error deleting document:", err);
    res.status(500).json({ error: "Failed to delete document" });
  }
};