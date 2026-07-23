## Files

- **schema.sql** – Creates all database tables and constraints.
- **test.sql** – Contains sample SQL query for inserting test data.

## Database Connection (For our development phase)

1. Open PostgreSQL and create a database named **NeighborShare**.
2. Use your preferred password 
3. Open the Query Tool in pgAdmin.
4. Run **schema.sql** to create the database tables.
5. Run **test.sql** to insert and test sample data (optional).
6. Start the Express backend. It connects to PostgreSQL using the settings in `backend/.env`.