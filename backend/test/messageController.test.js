const pool = require("../src/config/db");
const {
    getMessagesByRecipient,
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

    test("retrieves an authenticated recipient's messages in chronological order", async () => {
        const messages = [
            { message_id: 1, donor_id: 4, recipient_id: 2, message: "First", sent_at: "2026-01-01T10:00:00.000Z", is_read: false },
            { message_id: 2, donor_id: 4, recipient_id: 2, message: "Second", sent_at: "2026-01-01T10:05:00.000Z", is_read: true }
        ];
        const req = { params: { recipientId: "2" }, user: { recipient_id: 2 } };
        const res = createResponse();
        pool.query.mockResolvedValueOnce({ rows: messages });

        await getMessagesByRecipient(req, res);

        expect(pool.query).toHaveBeenCalledWith(
            expect.stringContaining("ORDER BY sent_at ASC"),
            [2]
        );
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(messages);
    });

    test("rejects requests without an authenticated recipient", async () => {
        const req = { params: { recipientId: "2" }, user: undefined };
        const res = createResponse();

        await getMessagesByRecipient(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(401);
    });

    test("prevents an authenticated recipient from retrieving another recipient's messages", async () => {
        const req = { params: { recipientId: "7" }, user: { recipient_id: 2 } };
        const res = createResponse();

        await getMessagesByRecipient(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(403);
    });

    test("marks the authenticated recipient's messages as read", async () => {
        const req = {
            params: { recipientId: "2" },
            user: { recipient_id: 2 },
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

    test("rejects an unauthorized mark-read request before querying", async () => {
        const req = {
            params: { recipientId: "7" },
            user: { recipient_id: 2 },
            body: { message_ids: [1] }
        };
        const res = createResponse();

        await markMessagesAsRead(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(403);
    });

    test("rejects an unauthenticated mark-read request", async () => {
        const req = {
            params: { recipientId: "2" },
            body: { message_ids: [1] }
        };
        const res = createResponse();

        await markMessagesAsRead(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(401);
    });

    test("sends a message from the authenticated recipient to a donor", async () => {
        const req = {
            user: { recipient_id: 2 },
            body: { donor_id: "4", message: "  Is the food available?  " }
        };
        const res = createResponse();
        const createdMessage = {
            message_id: 10,
            donor_id: 4,
            recipient_id: 2,
            message: "Is the food available?",
            sent_at: "2026-01-01T10:00:00.000Z",
            is_read: false
        };

        pool.query
            .mockResolvedValueOnce({ rows: [{ recipient_id: 2 }] })
            .mockResolvedValueOnce({ rows: [{ donor_id: 4 }] })
            .mockResolvedValueOnce({ rows: [createdMessage] });

        await sendMessage(req, res);

        expect(pool.query).toHaveBeenCalledTimes(3);
        expect(pool.query).toHaveBeenLastCalledWith(
            expect.stringContaining("INSERT INTO messages"),
            [4, 2, "Is the food available?"]
        );
        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(createdMessage);
    });

    test.each([
        ["empty message", ""],
        ["whitespace-only message", "   "]
    ])("rejects an %s", async (_description, message) => {
        const req = {
            user: { recipient_id: 2 },
            body: { donor_id: 4, message }
        };
        const res = createResponse();

        await sendMessage(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("rejects a missing or invalid donor ID", async () => {
        const req = {
            user: { recipient_id: 2 },
            body: { message: "Hello" }
        };
        const res = createResponse();

        await sendMessage(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("rejects an unauthenticated sender", async () => {
        const req = { body: { donor_id: 4, message: "Hello" } };
        const res = createResponse();

        await sendMessage(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(401);
    });

    test("returns 404 when the target donor does not exist", async () => {
        const req = {
            user: { recipient_id: 2 },
            body: { donor_id: 999, message: "Hello" }
        };
        const res = createResponse();

        pool.query
            .mockResolvedValueOnce({ rows: [{ recipient_id: 2 }] })
            .mockResolvedValueOnce({ rows: [] });

        await sendMessage(req, res);

        expect(pool.query).toHaveBeenCalledTimes(2);
        expect(res.status).toHaveBeenCalledWith(404);
    });

    test("returns 500 when message persistence fails", async () => {
        const req = {
            user: { recipient_id: 2 },
            body: { donor_id: 4, message: "Hello" }
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