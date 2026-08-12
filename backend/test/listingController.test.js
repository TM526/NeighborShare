const pool = require("../src/config/db");
const {
    createListing,
    updateListing
} = require("../src/controllers/listingController");

jest.mock("../src/config/db", () => ({
    query: jest.fn()
}));

const createResponse = () => {
    const res = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    return res;
};

const listingBody = (overrides = {}) => ({
    account_id: 1,
    food_name: "Vegetable Soup",
    category: "Cooked Meals",
    quantity: "2 containers",
    pickup_location: "Community Centre",
    description: "Fresh soup",
    ...overrides
});

describe("listingController expiry date", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    test("saves a valid expiry_date when creating a listing", async () => {
        const req = { body: listingBody({ expiry_date: "2026-12-31" }) };
        const res = createResponse();

        pool.query
            .mockResolvedValueOnce({ rows: [{ donor_id: 4 }] })
            .mockResolvedValueOnce({
                rows: [{ listing_id: 10, expiry_date: "2026-12-31" }]
            });

        await createListing(req, res);

        expect(pool.query).toHaveBeenLastCalledWith(
            expect.stringContaining("expiry_date"),
            [
                4,
                "Vegetable Soup",
                "Cooked Meals",
                "2 containers",
                "Community Centre",
                "Fresh soup",
                "2026-12-31",
                "Available"
            ]
        );
        expect(res.status).toHaveBeenCalledWith(201);
    });

    test("allows a listing without expiry_date", async () => {
        const req = { body: listingBody() };
        const res = createResponse();

        pool.query
            .mockResolvedValueOnce({ rows: [{ donor_id: 4 }] })
            .mockResolvedValueOnce({ rows: [{ listing_id: 10, expiry_date: null }] });

        await createListing(req, res);

        expect(pool.query).toHaveBeenLastCalledWith(
            expect.stringContaining("expiry_date"),
            expect.arrayContaining([null, "Available"])
        );
        expect(res.status).toHaveBeenCalledWith(201);
    });

    test("rejects an invalid expiry_date", async () => {
        const req = { body: listingBody({ expiry_date: "2026-02-30" }) };
        const res = createResponse();

        await createListing(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("rejects an invalid expiry_date when updating a listing", async () => {
        const req = {
            params: { id: "10" },
            body: {
                food_name: "Vegetable Soup",
                category: "Cooked Meals",
                quantity: "2 containers",
                pickup_location: "Community Centre",
                description: "Fresh soup",
                status: "Available",
                expiry_date: "not-a-date"
            }
        };
        const res = createResponse();

        await updateListing(req, res);

        expect(pool.query).not.toHaveBeenCalled();
        expect(res.status).toHaveBeenCalledWith(400);
    });

    test("updates a listing with a valid expiry_date", async () => {
        const req = {
            params: { id: "10" },
            body: {
                food_name: "Vegetable Soup",
                category: "Cooked Meals",
                quantity: "2 containers",
                pickup_location: "Community Centre",
                description: "Fresh soup",
                status: "Available",
                expiry_date: "2027-01-15"
            }
        };
        const res = createResponse();

        pool.query.mockResolvedValueOnce({
            rows: [{ listing_id: 10, expiry_date: "2027-01-15" }]
        });

        await updateListing(req, res);

        expect(pool.query).toHaveBeenCalledWith(
            expect.stringContaining("COALESCE($7, expiry_date)"),
            [
                "Vegetable Soup",
                "Cooked Meals",
                "2 containers",
                "Community Centre",
                "Fresh soup",
                "Available",
                "2027-01-15",
                "10"
            ]
        );
        expect(res.status).toHaveBeenCalledWith(200);
    });
});
