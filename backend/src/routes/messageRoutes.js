const express = require("express");
const router = express.Router();

const { getMessagesByRecipient } = require("../controllers/messageController");

router.get("/:recipientId", getMessagesByRecipient);

module.exports = router;