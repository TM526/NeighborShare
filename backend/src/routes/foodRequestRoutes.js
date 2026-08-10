const express = require("express");

const router = express.Router();

const {
    createFoodRequest,
    getAllFoodRequests,
    getFoodRequestById,
    getRequestsByDonor,
    updateFoodRequestStatus,
    deleteFoodRequest
} = require("../controllers/foodRequestController");

router.post("/", createFoodRequest);
router.get("/", getAllFoodRequests);
router.get("/donor/:accountId", getRequestsByDonor);
router.get("/:id", getFoodRequestById);
router.put("/:id/status", updateFoodRequestStatus);
router.delete("/:id", deleteFoodRequest);

module.exports = router;