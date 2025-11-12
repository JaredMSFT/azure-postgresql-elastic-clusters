-- Create a table to hold shared geographic information

CREATE TABLE geo_ips (
  addrs cidr NOT NULL PRIMARY KEY,
  latlon point NOT NULL
    CHECK (-90  <= latlon[0] AND latlon[0] <= 90 AND
           -180 <= latlon[1] AND latlon[1] <= 180)
);
CREATE INDEX ON geo_ips USING gist (addrs inet_ops);

-- Next make geo_ips a "reference table" to store a copy of the table on every worker node.

SELECT create_reference_table('geo_ips');