-- Migration: brings smritiiilamaa/NeighborShare's live database in sync with
-- the messaging, incident-reports, and listing-flagging work built this
-- session. Written for the ACTUAL live DB, where `messages` and
-- `incident_reports` already exist in an older shape -- CREATE TABLE IF NOT
-- EXISTS alone would silently skip fixing them, so this also ALTERs them
-- into the shape the new backend code expects. Safe to re-run.

-- Listings: expiry date (from Sahil's PR) + flagging/moderation columns.
ALTER TABLE food_listings
    ADD COLUMN IF NOT EXISTS expiry_date DATE,
    ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS flag_reason TEXT,
    ADD COLUMN IF NOT EXISTS flagged_by VARCHAR(150),
    ADD COLUMN IF NOT EXISTS flagged_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS moderation_status VARCHAR(20) NOT NULL DEFAULT 'Pending';

ALTER TABLE food_listings
    DROP CONSTRAINT IF EXISTS food_listings_moderation_status_check;

ALTER TABLE food_listings
    ADD CONSTRAINT food_listings_moderation_status_check
        CHECK (moderation_status IN ('Pending', 'Under Review', 'Resolved'));

-- Messages: table already exists on the live DB -- create it only if truly
-- missing, then patch in the one column it's missing (is_read).
CREATE TABLE IF NOT EXISTS messages (
    message_id SERIAL PRIMARY KEY,
    donor_id INTEGER NOT NULL,
    recipient_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_messages_donor FOREIGN KEY (donor_id)
        REFERENCES donor_profiles(donor_id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_recipient FOREIGN KEY (recipient_id)
        REFERENCES recipient_profiles(recipient_id) ON DELETE CASCADE
);

ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT FALSE;

-- Incident reports: table already exists on the live DB with a different
-- shape (admin_id NOT NULL, no reported_by/updated_at, no status check).
-- Create it only if truly missing, then patch the live shape into what
-- incidentController.js actually expects.
CREATE TABLE IF NOT EXISTS incident_reports (
    incident_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    reported_by VARCHAR(150),
    status VARCHAR(20) NOT NULL DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE incident_reports
    ADD COLUMN IF NOT EXISTS reported_by VARCHAR(150),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE incident_reports
    ALTER COLUMN title TYPE VARCHAR(200);

-- admin_id only exists on the live table's old shape -- drop its NOT NULL
-- so inserts that don't supply it (ours don't) succeed. Guarded because a
-- fresh install of the CREATE TABLE above never has this column at all.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'incident_reports' AND column_name = 'admin_id'
    ) THEN
        ALTER TABLE incident_reports ALTER COLUMN admin_id DROP NOT NULL;
    END IF;
END $$;

ALTER TABLE incident_reports
    DROP CONSTRAINT IF EXISTS incident_reports_status_check;

ALTER TABLE incident_reports
    ADD CONSTRAINT incident_reports_status_check
        CHECK (status IN ('Open', 'Investigating', 'Resolved'));
