const pool = require("../src/config/db");
const {
    createIncidentReport,
    getAllIncidentReports,
    updateIncidentStatus
} = require("../src/controllers/incidentController");

jest.mock("../src/config/db", () => ({
    query: jest.fn()
}));

const createResponse = () => {
    const res = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    return res;
};

describe("incidentController", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    test("creates an incident report", async () => {
        const req = {
            body: {
                title: "  Inappropriate listing  ",
                description: "  Contains offensive content.  ",
                reported_by: "Admin User"
            }
        };
        const res = createResponse();
        const created = {
            incident_id: 1,
            title: "Inappropriate listing",
            description: "Contains offensive content.",
            reported_by: "Admin User",
            status: "Open"
        };
        pool.query.mockResolvedValueOnce({ rows: [created] });

        await createIncidentReport(req, res);

        expect(pool.query).toHaveBeenCalledWith(
            expect.stringContaining("INSERT INTO incident_reports"),
            ["Inappropriate listing", "Contains offensive content.", "Admin User"]
        );
        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(created);
    });

    test("rejects a report with a missing title or description", async () => {
        const req = { body: { title: "", description: "" } };
        const res = createResponse();

        await createIncidentReport(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("retrieves all incident reports newest first", async () => {
        const reports = [
            { incident_id: 2, title: "B" },
            { incident_id: 1, title: "A" }
        ];
        const req = {};
        const res = createResponse();
        pool.query.mockResolvedValueOnce({ rows: reports });

        await getAllIncidentReports(req, res);

        expect(pool.query).toHaveBeenCalledWith(
            expect.stringContaining("ORDER BY created_at DESC")
        );
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(reports);
    });

    test("updates an incident report's status", async () => {
        const req = { params: { id: "1" }, body: { status: "Investigating" } };
        const res = createResponse();
        const updated = { incident_id: 1, status: "Investigating" };
        pool.query.mockResolvedValueOnce({ rows: [updated] });

        await updateIncidentStatus(req, res);

        expect(pool.query).toHaveBeenCalledWith(
            expect.stringContaining("UPDATE incident_reports"),
            ["Investigating", "1"]
        );
        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(updated);
    });

    test("rejects an invalid status value", async () => {
        const req = { params: { id: "1" }, body: { status: "Closed" } };
        const res = createResponse();

        await updateIncidentStatus(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("returns 404 when updating a non-existent incident report", async () => {
        const req = { params: { id: "999" }, body: { status: "Resolved" } };
        const res = createResponse();
        pool.query.mockResolvedValueOnce({ rows: [] });

        await updateIncidentStatus(req, res);

        expect(res.status).toHaveBeenCalledWith(404);
    });
});
