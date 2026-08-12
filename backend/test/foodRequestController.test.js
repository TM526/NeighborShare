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

const createRequest = ({ body = {}, params = {}, query = {} } = {}) => ({ body, params, query });

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

  test("verifies a food request belongs to the correct recipient", async () => {
    const req = createRequest({ params: { id: "101" }, query: { recipient_id: "2" } });
    const res = createResponse();

    pool.query.mockResolvedValueOnce({ rows: [{ request_id: 101, listing_id: 1, recipient_id: 2, request_status: "Pending" }] });

    await getFoodRequestById(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ request_id: 101, request_status: "Pending" }));
  });

  test("returns 403 when recipient does not own the request", async () => {
    const req = createRequest({ params: { id: "101" }, query: { recipient_id: "7" } });
    const res = createResponse();

    pool.query.mockResolvedValueOnce({ rows: [{ request_id: 101, listing_id: 1, recipient_id: 2, request_status: "Pending" }] });

    await getFoodRequestById(req, res);

    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith({ message: "Request does not belong to this recipient." });
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

  test("updates a request status to Cancelled and changes listing to Available", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);
    client.query
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({ rows: [{ request_id: 103, listing_id: 3, request_status: "Cancelled" }] })
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({});

    const req = createRequest({ params: { id: "103" }, body: { request_status: "Cancelled" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(client.query).toHaveBeenCalledWith("BEGIN");
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_requests"),
      ["Cancelled", "103"]
    );
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_listings"),
      ["Available", 3]
    );
    expect(client.query).toHaveBeenCalledWith("COMMIT");
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: "Food request status updated successfully.",
        request: expect.objectContaining({ request_status: "Cancelled" }),
      })
    );
    expect(client.release).toHaveBeenCalled();
  });

  test("updates a request status to Completed and changes listing to Collected", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);
    client.query
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({ rows: [{ request_id: 104, listing_id: 4, request_status: "Completed" }] })
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({});

    const req = createRequest({ params: { id: "104" }, body: { request_status: "Completed" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(client.query).toHaveBeenCalledWith("BEGIN");
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_requests"),
      ["Completed", "104"]
    );
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_listings"),
      ["Collected", 4]
    );
    expect(client.query).toHaveBeenCalledWith("COMMIT");
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: "Food request status updated successfully.",
        request: expect.objectContaining({ request_status: "Completed" }),
      })
    );
    expect(client.release).toHaveBeenCalled();
  });

  test("updates a request status to Pending without changing listing status", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);
    client.query
      .mockResolvedValueOnce({})
      .mockResolvedValueOnce({ rows: [{ request_id: 105, listing_id: 5, request_status: "Pending" }] })
      .mockResolvedValueOnce({});

    const req = createRequest({ params: { id: "105" }, body: { request_status: "Pending" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(client.query).toHaveBeenCalledWith("BEGIN");
    expect(client.query).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE food_requests"),
      ["Pending", "105"]
    );
    // Verify that food_listings was NOT updated for Pending status
    const listingUpdateCalls = client.query.mock.calls.filter(call =>
      call[0]?.includes("UPDATE food_listings")
    );
    expect(listingUpdateCalls.length).toBe(0);
    expect(client.query).toHaveBeenCalledWith("COMMIT");
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: "Food request status updated successfully.",
        request: expect.objectContaining({ request_status: "Pending" }),
      })
    );
    expect(client.release).toHaveBeenCalled();
  });

  test("returns 400 when request_status is missing or empty", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);

    const req = createRequest({ params: { id: "106" }, body: { request_status: "" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ message: "Request status is required." });
    expect(client.release).toHaveBeenCalled();
  });

  test("returns 500 on database connection error during status update", async () => {
    const client = { query: jest.fn(), release: jest.fn() };
    pool.connect.mockResolvedValueOnce(client);
    client.query
      .mockRejectedValueOnce(new Error("Connection lost"));

    const req = createRequest({ params: { id: "107" }, body: { request_status: "Approved" } });
    const res = createResponse();

    await updateFoodRequestStatus(req, res);

    expect(client.query).toHaveBeenCalledWith("ROLLBACK");
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith({ message: "Error updating food request status." });
    expect(client.release).toHaveBeenCalled();
  });
});
