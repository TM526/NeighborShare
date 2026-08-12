const pool = require("../src/config/db");
const {
  createFoodRequest,
  getFoodRequestById,
  updateFoodRequestStatus,
} = require("../src/controllers/foodRequestController");

jest.mock("../src/config/db", () => ({
  query: jest.fn(),
  connect: jest.fn(),
}));

const createResponse = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  return res;
};

const createRequest = ({ body = {}, params = {} } = {}) => ({ body, params });

describe("foodRequestController", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("creates a food request and returns Pending status by default", async () => {
    const req = createRequest({
      body: { listing_id: 1, recipient_id: 2, message: "Please reserve" },
    });
    const res = createResponse();

    pool.query
      .mockResolvedValueOnce({ rows: [{ recipient_id: 2 }] })
      .mockResolvedValueOnce({ rows: [{ listing_id: 1, status: "Available" }] })
      .mockResolvedValueOnce({ rows: [{ request_id: 101, listing_id: 1, recipient_id: 2, request_status: "Pending", message: "Please reserve" }] });

    await createFoodRequest(req, res);

    expect(pool.query).toHaveBeenCalledTimes(3);
    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        request_id: 101,
        request_status: "Pending",
      })
    );
  });

  test("returns 409 for duplicate request condition", async () => {
    const req = createRequest({ body: { listing_id: 1, recipient_id: 2, message: "Please reserve" } });
    const res = createResponse();

    pool.query
      .mockResolvedValueOnce({ rows: [{ recipient_id: 2 }] })
      .mockResolvedValueOnce({ rows: [{ listing_id: 1, status: "Available" }] })
      .mockRejectedValueOnce({ code: "23505" });

    await createFoodRequest(req, res);

    expect(res.status).toHaveBeenCalledWith(409);
    expect(res.json).toHaveBeenCalledWith({ message: "This recipient has already requested this listing." });
  });

  test("retrieves a food request by ID", async () => {
    const req = createRequest({ params: { id: "101" } });
    const res = createResponse();

    pool.query.mockResolvedValueOnce({ rows: [{ request_id: 101, listing_id: 1, recipient_id: 2, request_status: "Pending" }] });

    await getFoodRequestById(req, res);

    expect(pool.query).toHaveBeenCalledWith(
      expect.stringContaining("SELECT"),
      ["101"]
    );
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ request_id: 101 }));
  });

  test("returns 404 for a missing food request", async () => {
    const req = createRequest({ params: { id: "999" } });
    const res = createResponse();

    pool.query.mockResolvedValueOnce({ rows: [] });

    await getFoodRequestById(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({ message: "Food request not found." });
  });

  test("updates a request status to Approved successfully", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);
    client.query
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({ rows: [{ request_id: 101, listing_id: 1, request_status: "Approved" }] })
      .mockResolvedValueOnce({});

    const req = createRequest({ params: { id: "101" }, body: { request_status: "Approved" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(client.query).toHaveBeenCalledWith("BEGIN");
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_requests"),
      ["Approved", "101"]
    );
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_listings"),
      ["Reserved", 1]
    );
    expect(client.query).toHaveBeenCalledWith("COMMIT");
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: "Food request status updated successfully.",
        request: expect.objectContaining({ request_status: "Approved" }),
      })
    );
    expect(client.release).toHaveBeenCalled();
  });

  test("updates a request status to Rejected successfully", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);
    client.query
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({ rows: [{ request_id: 102, listing_id: 2, request_status: "Rejected" }] })
      .mockResolvedValueOnce({});

    const req = createRequest({ params: { id: "102" }, body: { request_status: "Rejected" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(client.query).toHaveBeenCalledWith("BEGIN");
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_requests"),
      ["Rejected", "102"]
    );
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_listings"),
      ["Available", 2]
    );
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: "Food request status updated successfully.",
        request: expect.objectContaining({ request_status: "Rejected" }),
      })
    );
    expect(client.release).toHaveBeenCalled();
  });

  test("rejects an unsupported request status", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);

    const req = createRequest({ params: { id: "101" }, body: { request_status: "InvalidStatus" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ message: "Invalid request status." });
    expect(client.release).toHaveBeenCalled();
  });

  test("returns 404 when updating a non-existent request", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);
    client.query
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({ rows: [] });

    const req = createRequest({ params: { id: "999" }, body: { request_status: "Approved" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({ message: "Food request not found." });
    expect(client.release).toHaveBeenCalled();
  });
});
