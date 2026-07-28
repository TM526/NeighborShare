const pool = require("../config/db");
const bcrypt = require("bcryptjs");

const createAccount = async (req, res) => {
    try {
        const { email, password, role } = req.body;

        if (!email?.trim() || !password?.trim() || !role?.trim()) {
            return res.status(400).json({
                message: "Email, password and role are required."
            });
        }

        const normalizedEmail = email.trim().toLowerCase();
        const normalizedRole = role.trim();

        if (!["Donor", "Recipient"].includes(normalizedRole)) {
            return res.status(400).json({
                message: "Role must be Donor or Recipient."
            });
        }

        const existingAccount = await pool.query(
            `SELECT account_id
             FROM user_accounts
             WHERE email = $1`,
            [normalizedEmail]
        );

        if (existingAccount.rows.length > 0) {
            return res.status(409).json({
                message: "An account with this email already exists."
            });
        }

        const passwordHash = await bcrypt.hash(password.trim(), 10);

        const result = await pool.query(
            `INSERT INTO user_accounts
            (
                email,
                password_hash,
                role
            )
            VALUES ($1, $2, $3)
            RETURNING account_id, email, role`,
            [
                normalizedEmail,
                passwordHash,
                normalizedRole
            ]
        );

        return res.status(201).json({
            message: "Account created successfully.",
            account: result.rows[0]
        });

    } catch (error) {
        console.error(error);

        if (error.code === "23505") {
            return res.status(409).json({
                message: "An account with this email already exists."
            });
        }

        return res.status(500).json({
            message: "Error creating account."
        });
    }
};

module.exports = {
    createAccount
};