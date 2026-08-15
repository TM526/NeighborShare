const pool = require("../src/config/db");
const {
    getMessagesByRecipient,
    getConversation,
    markMessagesAsRead,
    sendMessage
} = require("../src/controllers/messageController");

jest.mock("../src/config/db", () => ({
    query: jest.fn()
}));

const createResponse = () => {
    const res = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    return res;
};

describe("messageController", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    test("retrieves a recipient's messages in chronological order", async () => {
        const messages = [
            { message_id: 1, donor_id: 4, recipient_id: 2, message: "First", sent_at: "2026-01-01T10:00:00.000Z", is_read: false },
            { message_id: 2, donor_id: 4, recipient_id: 2, message: "Second", sent_at: "2026-01-01T10:05:00.000Z", is_read: true }
        ];
        const req = { params: { recipientId: "2" } };
        const res = createResponse();
        pool.query
            .mockResolvedValueOnce({ rows: [{ recipient_id: 2 }] })
            .mockResolvedValueOnce({ rows: messages });

        await getMessagesByRecipient(req, res);

        expect(pool.query).toHaveBeenLastCalledWith(
            expect.stringContaining("ORDER BY sent_at ASC"),
            ["2"]
        );
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(messages);
    });

    test("returns 404 when the recipient does not exist", async () => {
        const req = { params: { recipientId: "999" } };
        const res = createResponse();
        pool.query.mockResolvedValueOnce({ rows: [] });

        await getMessagesByRecipient(req, res);

        expect(pool.query).toHaveBeenCalledTimes(1);
        expect(res.status).toHaveBeenCalledWith(404);
    });

    test("retrieves the conversation between a donor and recipient", async () => {
        const messages = [
            { message_id: 1, donor_id: 4, recipient_id: 2, message: "Hi", sent_at: "2026-01-01T10:00:00.000Z", is_read: false }
        ];
        const req = { query: { donorId: "4", recipientId: "2" } };
        const res = createResponse();
        pool.query.mockResolvedValueOnce({ rows: messages });

        await getConversation(req, res);

        expect(pool.query).toHaveBeenCalledWith(
            expect.stringContaining("WHERE donor_id = $1 AND recipient_id = $2"),
            [4, 2]
        );
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(messages);
    });

    test("rejects a conversation lookup with invalid IDs", async () => {
        const req = { query: { donorId: "abc", recipientId: "2" } };
        const res = createResponse();

        await getConversation(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("marks a recipient's messages as read", async () => {
        const req = {
            params: { recipientId: "2" },
            body: { message_ids: [1, 2] }
        };
        const res = createResponse();
        pool.query.mockResolvedValueOnce({
            rows: [{ message_id: 1, is_read: true }, { message_id: 2, is_read: true }]
        });

        await markMessagesAsRead(req, res);

        expect(pool.query).toHaveBeenCalledWith(
            expect.stringContaining("SET is_read = TRUE"),
            [2, [1, 2]]
        );
        expect(res.status).toHaveBeenCalledWith(200);
    });

    test("rejects a mark-read request with no message IDs", async () => {
        const req = {
            params: { recipientId: "2" },
            body: { message_ids: [] }
        };
        const res = createResponse();

        await markMessagesAsRead(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("sends a message from a recipient to a donor", async () => {
        const req = {
            body: {
                donor_id: "4",
                recipient_id: "2",
                message: "  Is the food available?  ",
                sender_role: "Recipient"
            }
        };
        const res = createResponse();
        const createdMessage = {
            message_id: 10,
            donor_id: 4,
            recipient_id: 2,
            message: "Is the food available?",
            sent_at: "2026-01-01T10:00:00.000Z",
            is_read: false,
            sender_role: "Recipient"
        };

        pool.query
            .mockResolvedValueOnce({ rows: [{ recipient_id: 2 }] })
            .mockResolvedValueOnce({ rows: [{ donor_id: 4 }] })
            .mockResolvedValueOnce({ rows: [createdMessage] });

        await sendMessage(req, res);

        expect(pool.query).toHaveBeenCalledTimes(3);
        expect(pool.query).toHaveBeenLastCalledWith(
            expect.stringContaining("INSERT INTO messages"),
            [4, 2, "Is the food available?", "Recipient"]
        );
        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(createdMessage);
    });

    test("rejects a missing or invalid sender_role", async () => {
        const req = {
            body: { donor_id: 4, recipient_id: 2, message: "Hello" }
        };
        const res = createResponse();

        await sendMessage(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test.each([
        ["empty message", ""],
        ["whitespace-only message", "   "]
    ])("rejects an %s", async (_description, message) => {
        const req = {
            body: { donor_id: 4, recipient_id: 2, message, sender_role: "Recipient" }
        };
        const res = createResponse();

        await sendMessage(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("rejects a missing or invalid donor ID", async () => {
        const req = {
            body: { recipient_id: 2, message: "Hello" }
        };
        const res = createResponse();

        await sendMessage(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("rejects a missing or invalid recipient ID", async () => {
        const req = {
            body: { donor_id: 4, message: "Hello" }
        };
        const res = createResponse();

        await sendMessage(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test.each([
        "That's a damn good idea",
        "What the hell is this",
        "This is shit"
    ])("rejects a message containing profanity: '%s'", async (message) => {
        const req = {
            body: { donor_id: 4, recipient_id: 2, message, sender_role: "Recipient" }
        };
        const res = createResponse();

        await sendMessage(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
        expect(res.json).toHaveBeenCalledWith(
            expect.objectContaining({
                message: expect.stringContaining("inappropriate")
            })
        );
    });

    test("returns 404 when the target donor does not exist", async () => {
        const req = {
            body: { donor_id: 999, recipient_id: 2, message: "Hello", sender_role: "Recipient" }
        };
        const res = createResponse();

        pool.query
            .mockResolvedValueOnce({ rows: [{ recipient_id: 2 }] })
            .mockResolvedValueOnce({ rows: [] });

        await sendMessage(req, res);

        expect(pool.query).toHaveBeenCalledTimes(2);
        expect(res.status).toHaveBeenCalledWith(404);
    });

    test("returns 404 when the sending recipient does not exist", async () => {
        const req = {
            body: { donor_id: 4, recipient_id: 999, message: "Hello", sender_role: "Recipient" }
        };
        const res = createResponse();

        pool.query.mockResolvedValueOnce({ rows: [] });

        await sendMessage(req, res);

        expect(pool.query).toHaveBeenCalledTimes(1);
        expect(res.status).toHaveBeenCalledWith(404);
    });

    test("returns 500 when message persistence fails", async () => {
        const req = {
            body: { donor_id: 4, recipient_id: 2, message: "Hello", sender_role: "Recipient" }
        };
        const res = createResponse();

        pool.query
            .mockResolvedValueOnce({ rows: [{ recipient_id: 2 }] })
            .mockResolvedValueOnce({ rows: [{ donor_id: 4 }] })
            .mockRejectedValueOnce(new Error("Connection lost"));

        await sendMessage(req, res);

        expect(res.status).toHaveBeenCalledWith(500);
        expect(res.json).toHaveBeenCalledWith({ message: "Error sending message." });
    });
});
