const pool = require("../config/db");

const getReportSummary = async (req, res) => {
  try {
    const [
      donorResult,
      recipientResult,
      listingResult,
      requestResult,
      pendingResult,
      approvedResult,
      recentListingsResult,
      recentRequestsResult,
    ] = await Promise.all([
      pool.query("SELECT COUNT(*) AS count FROM donor_profiles"),
      pool.query("SELECT COUNT(*) AS count FROM recipient_profiles"),
      pool.query("SELECT COUNT(*) AS count FROM food_listings"),
      pool.query("SELECT COUNT(*) AS count FROM food_requests"),
      pool.query(
        "SELECT COUNT(*) AS count FROM food_requests WHERE request_status = 'Pending'"
      ),
      pool.query(
        "SELECT COUNT(*) AS count FROM food_requests WHERE request_status = 'Approved'"
      ),
      pool.query(
        "SELECT COUNT(*) AS count FROM food_listings WHERE created_at >= NOW() - INTERVAL '7 days'"
      ),
      pool.query(
        "SELECT COUNT(*) AS count FROM food_requests WHERE requested_at >= NOW() - INTERVAL '7 days'"
      ),
    ]);

    return res.status(200).json({
      totalDonors: Number(donorResult.rows[0].count || 0),
      totalRecipients: Number(recipientResult.rows[0].count || 0),
      totalListings: Number(listingResult.rows[0].count || 0),
      totalRequests: Number(requestResult.rows[0].count || 0),
      pendingRequests: Number(pendingResult.rows[0].count || 0),
      approvedRequests: Number(approvedResult.rows[0].count || 0),
      recentListings7d: Number(recentListingsResult.rows[0].count || 0),
      recentRequests7d: Number(recentRequestsResult.rows[0].count || 0),
    });
  } catch (error) {
    console.error("Error retrieving report summary:", error);

    return res.status(500).json({
      message: "Unable to retrieve report summary.",
    });
  }
};

module.exports = {
  getReportSummary,
};
