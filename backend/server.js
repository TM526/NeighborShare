const app = require("./src/app");

const PORT = 3000;

app.get("/", (req, res) => {
    res.send("NeighborShare Backend ACTIVE!");
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});