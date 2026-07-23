const express = require("express");

const router = express.Router();

const {
    createListing,
    getAllListings,
    getListingById,
    updateListing,
    deleteListing
} = require("../controllers/listingController");

router.post("/", createListing);
router.get("/", getAllListings);
router.get("/:id", getListingById);
router.put("/:id", updateListing);
router.delete("/:id", deleteListing);

module.exports = router;