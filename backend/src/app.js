const express = require("express");
const cors = require("cors");

const donorRoutes = require("./routes/donorRoutes");

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/donors", donorRoutes);

module.exports = app;