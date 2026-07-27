const pool = require("../config/db");

const createDonor = async (req, res) => {
    try {
        const {
            account_id,
            full_name,
            email,
            phone_number,
            street_address,
            city,
            postal_code
        } = req.body;

        if (
            !account_id ||
            !full_name?.trim() ||
            !email?.trim() ||
            !phone_number?.trim() ||
            !street_address?.trim() ||
            !city?.trim() ||
            !postal_code?.trim()
        ) {
            return res.status(400).json({
                message: "Account ID and all profile fields are required."
            });
        }

        const accountResult = await pool.query(
            `SELECT account_id, email, role
             FROM user_accounts
             WHERE account_id = $1`,
            [account_id]
        );

        if (accountResult.rows.length === 0) {
            return res.status(404).json({
                message: "Donor account not found."
            });
        }

        const account = accountResult.rows[0];

        if (account.role !== "Donor") {
            return res.status(403).json({
                message: "This account is not registered as a donor."
            });
        }

        if (account.email !== email.trim().toLowerCase()) {
            return res.status(400).json({
                message: "Profile email must match the donor account email."
            });
        }

        const result = await pool.query(
            `INSERT INTO donor_profiles
            (
                account_id,
                full_name,
                email,
                phone_number,
                street_address,
                city,
                postal_code
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *`,
            [
                account_id,
                full_name.trim(),
                email.trim().toLowerCase(),
                phone_number.trim(),
                street_address.trim(),
                city.trim(),
                postal_code.trim().toUpperCase()
            ]
        );

        return res.status(201).json({
            message: "Donor profile created and associated with donor account.",
            donor: result.rows[0]
        });

    } catch (error) {
        console.error(error);

        if (error.code === "23505") {
            return res.status(409).json({
                message:
                    "A donor profile already exists for this account or email."
            });
        }

        if (error.code === "23503") {
            return res.status(400).json({
                message: "The provided donor account does not exist."
            });
        }

        return res.status(500).json({
            message: "Error creating donor profile."
        });
    }
};

const getAllDonors = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT *
             FROM donor_profiles
             ORDER BY donor_id ASC`
        );

        return res.status(200).json(result.rows);
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            message: "Error retrieving donor profiles."
        });
    }
};

const getDonorById = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            `SELECT *
             FROM donor_profiles
             WHERE donor_id = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "Donor profile not found."
            });
        }

        return res.status(200).json(result.rows[0]);
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            message: "Error retrieving donor profile."
        });
    }
};

const updateDonor = async (req, res) => {
    try {
        const { id } = req.params;

        const {
            full_name,
            email,
            phone_number,
            street_address,
            city,
            postal_code
        } = req.body;

        if (
            !full_name?.trim() ||
            !email?.trim() ||
            !phone_number?.trim() ||
            !street_address?.trim() ||
            !city?.trim() ||
            !postal_code?.trim()
        ) {
            return res.status(400).json({
                message: "All fields are required."
            });
        }

        const result = await pool.query(
            `UPDATE donor_profiles
             SET full_name = $1,
                 email = $2,
                 phone_number = $3,
                 street_address = $4,
                 city = $5,
                 postal_code = $6
             WHERE donor_id = $7
             RETURNING *`,
            [
                full_name.trim(),
                email.trim().toLowerCase(),
                phone_number.trim(),
                street_address.trim(),
                city.trim(),
                postal_code.trim().toUpperCase(),
                id
            ]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "Donor profile not found."
            });
        }

        return res.status(200).json(result.rows[0]);
    } catch (error) {
        console.error(error);

        if (error.code === "23505") {
            return res.status(409).json({
                message: "A donor profile with this email already exists."
            });
        }

        return res.status(500).json({
            message: "Error updating donor profile."
        });
    }
};

const deleteDonor = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            `DELETE FROM donor_profiles
             WHERE donor_id = $1
             RETURNING *`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "Donor profile not found."
            });
        }

        return res.status(200).json({
            message: "Donor profile deleted successfully.",
            donor: result.rows[0]
        });
    } catch (error) {
        console.error(error);

        return res.status(500).json({
            message: "Error deleting donor profile."
        });
    }
};


module.exports = {
    createDonor,
    getAllDonors,
    getDonorById,
    updateDonor,
    deleteDonor
};