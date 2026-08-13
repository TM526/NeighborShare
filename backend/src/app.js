const express = require("express");
const cors = require("cors");

const accountRoutes = require("./routes/accountRoutes");
const donorRoutes = require("./routes/donorRoutes");
const recipientRoutes = require("./routes/recipientRoutes");
const listingRoutes = require("./routes/listingRoutes");
const foodRequestRoutes = require("./routes/foodRequestRoutes");
const reportRoutes = require("./routes/reportRoutes");
const messageRoutes = require("./routes/messageRoutes");
const incidentRoutes = require("./routes/incidentRoutes");
const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/donors", donorRoutes);
app.use("/api/recipients", recipientRoutes);
app.use("/api/listings", listingRoutes);
app.use("/api/requests", foodRequestRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/accounts", accountRoutes);
app.use("/api/messages", messageRoutes);
app.use("/api/incidents", incidentRoutes);

module.exports = app;