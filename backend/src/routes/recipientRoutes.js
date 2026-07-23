const express = require("express");

const router = express.Router();

const {
    createRecipient,
    getAllRecipients,
    getRecipientById,
    updateRecipient,
    deleteRecipient
} = require("../controllers/recipientController");

router.post("/", createRecipient);
router.get("/", getAllRecipients);
router.get("/:id", getRecipientById);
router.put("/:id", updateRecipient);
router.delete("/:id", deleteRecipient);

module.exports = router;