const express = require("express");
const cors = require("cors");

const donorRoutes = require("./routes/donorRoutes");
const recipientRoutes = require("./routes/recipientRoutes");

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/donors", donorRoutes);
app.use("/api/recipients", recipientRoutes);
module.exports = app;