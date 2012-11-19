rm simcam.db
sqlite3 simcam.db < simcam.sql

dbicdump -o dump_directory=./lib \
    -o overwrite_modifications=1 \
     -o components='["InflateColumn::DateTime","Helper::Row::ToJSON", "Helper::ResultSet::Random"]' \
    SimCam::Schema dbi:SQLite:./simcam.db '{ quote_char => "\"" }'

