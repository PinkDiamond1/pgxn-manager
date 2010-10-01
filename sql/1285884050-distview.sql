-- sql/1285884050-distview.sql SQL Migration

SET client_min_messages TO warning;
SET log_min_messages    TO warning;

BEGIN;

CREATE VIEW distribution_details AS
SELECT d.name, d.version, d.abstract, d.description, d.relstatus, d.owner,
       d.sha1, d.meta,
       ('{' || string_agg(DISTINCT ARRAY[de.extension, de.ext_version]::text, ',' ORDER BY ARRAY[de.extension, de.ext_version]::text) || '}')::text[][] AS extensions,
       array_agg(DISTINCT dt.tag ORDER BY dt.tag) AS tags
  FROM distributions d
  JOIN distribution_extensions de
    ON d.name    = de.distribution
   AND d.version = de.dist_version
  LEFT JOIN distribution_tags dt
    ON d.name    = dt.distribution
   AND d.version = dt.version
 GROUP BY d.name, d.version, d.abstract, d.description, d.relstatus, d.owner,
       d.sha1, d.meta;

GRANT SELECT ON distribution_details TO pgxn;

COMMIT;
