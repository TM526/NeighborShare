const pool = require("../src/config/db");
const { getMessagesByRecipient } = require("../src/controllers/messageController");

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
            { message_id: 1, donor_id: 4, recipient_id: 2, message: "First", sent_at: "2026-01-01T10:00:00.000Z" },
            { message_id: 2, donor_id: 4, recipient_id: 2, message: "Second", sent_at: "2026-01-01T10:05:00.000Z" }
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
});