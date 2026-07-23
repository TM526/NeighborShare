const express = require("express");

const router = express.Router();

const {
    createDonor,
    getAllDonors,
    getDonorById,
    updateDonor,
    deleteDonor
} = require("../controllers/donorController");

router.post("/", createDonor);
router.get("/", getAllDonors);
router.get("/:id", getDonorById);
router.put("/:id", updateDonor);
router.delete("/:id", deleteDonor);

module.exports = router;