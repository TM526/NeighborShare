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
            `SELECT message_id, donor_id, recipient_id, message, sent_at
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

module.exports = {
    getMessagesByRecipient
};