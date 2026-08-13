const pool = require("../config/db");

const getMessagesByRecipient = async (req, res) => {
    try {
        const { recipientId } = req.params;
        const authenticatedRecipientId = req.user?.recipient_id;

        if (authenticatedRecipientId === undefined) {
            return res.status(401).json({
                message: "Authentication is required to retrieve messages."
            });
        }

        if (String(authenticatedRecipientId) !== String(recipientId)) {
            return res.status(403).json({
                message: "Messages do not belong to this recipient."
            });
        }

        const result = await pool.query(
            `SELECT message_id, donor_id, recipient_id, message, sent_at, is_read
             FROM messages
             WHERE recipient_id = $1
             ORDER BY sent_at ASC`,
            [authenticatedRecipientId]
        );

        return res.status(200).json(result.rows);
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            message: "Error retrieving messages."
        });
    }
};

const markMessagesAsRead = async (req, res) => {
    try {
        const { recipientId } = req.params;
        const authenticatedRecipientId = req.user?.recipient_id;
        const { message_ids: messageIds } = req.body || {};

        if (authenticatedRecipientId === undefined) {
            return res.status(401).json({
                message: "Authentication is required to update messages."
            });
        }

        if (String(authenticatedRecipientId) !== String(recipientId)) {
            return res.status(403).json({
                message: "Messages do not belong to this recipient."
            });
        }

        if (!Array.isArray(messageIds) || messageIds.length === 0) {
            return res.status(400).json({
                message: "At least one message ID is required."
            });
        }

        const result = await pool.query(
            `UPDATE messages
             SET is_read = TRUE
             WHERE recipient_id = $1
               AND message_id = ANY($2::int[])
             RETURNING message_id, is_read`,
            [authenticatedRecipientId, messageIds]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "No messages found for this recipient."
            });
        }

        return res.status(200).json({
            messages: result.rows
        });
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            message: "Error marking messages as read."
        });
    }
};

const sendMessage = async (req, res) => {
    try {
        const authenticatedRecipientId = req.user?.recipient_id;
        const { donor_id: donorId, message } = req.body || {};
        const parsedDonorId = Number(donorId);

        if (authenticatedRecipientId === undefined) {
            return res.status(401).json({
                message: "Authentication is required to send messages."
            });
        }

        if (!Number.isInteger(parsedDonorId) || parsedDonorId <= 0) {
            return res.status(400).json({
                message: "A valid donor ID is required."
            });
        }

        const trimmedMessage = message?.trim();

        if (!trimmedMessage) {
            return res.status(400).json({
                message: "Message content is required."
            });
        }

        const recipientResult = await pool.query(
            `SELECT recipient_id
             FROM recipient_profiles
             WHERE recipient_id = $1`,
            [authenticatedRecipientId]
        );

        if (recipientResult.rows.length === 0) {
            return res.status(401).json({
                message: "Authenticated recipient profile not found."
            });
        }

        const donorResult = await pool.query(
            `SELECT donor_id
             FROM donor_profiles
             WHERE donor_id = $1`,
            [parsedDonorId]
        );

        if (donorResult.rows.length === 0) {
            return res.status(404).json({
                message: "Donor profile not found."
            });
        }

        const result = await pool.query(
            `INSERT INTO messages (donor_id, recipient_id, message)
             VALUES ($1, $2, $3)
             RETURNING message_id, donor_id, recipient_id, message, sent_at, is_read`,
            [parsedDonorId, authenticatedRecipientId, trimmedMessage]
        );

        return res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            message: "Error sending message."
        });
    }
};

module.exports = {
    getMessagesByRecipient,
    markMessagesAsRead,
    sendMessage
};