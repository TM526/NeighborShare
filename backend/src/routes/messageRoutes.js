const express = require("express");
const router = express.Router();

const {
	getMessagesByRecipient,
	markMessagesAsRead,
	sendMessage
} = require("../controllers/messageController");

router.post("/", sendMessage);
router.patch("/:recipientId/read", markMessagesAsRead);
router.get("/:recipientId", getMessagesByRecipient);

module.exports = router;