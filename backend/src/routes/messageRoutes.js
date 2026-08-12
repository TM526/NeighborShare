const express = require("express");
const router = express.Router();

const {
	getMessagesByRecipient,
	markMessagesAsRead
} = require("../controllers/messageController");

router.patch("/:recipientId/read", markMessagesAsRead);
router.get("/:recipientId", getMessagesByRecipient);

module.exports = router;