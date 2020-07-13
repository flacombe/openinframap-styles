from funcs import (
    table,
    relation_tables,
    generalized_table,
    str_col,
    int_col,
    bool_col,
    type_col,
)


table(
    "telecom_cable",
    {
        "communication": ["line", "cable"],
        "construction:communication": ["line", "cable"],
    },
    "linestring",
    columns=[
        str_col("location"),
        str_col("operator"),
        type_col
    ],
)

table(
    "telecom_sites",
    {
        "telecom": ["data_center", "data_centre", "exchange", "connection_point", "distribution_point"]
    },
    ["points", "polygons"],
    columns=[
        str_col("operator"),
        str_col("telecom:medium"),
        str_col("connection_point"),
        str_col("ref"),
        str_col("ref:FR:ARCEP"),
        str_col("ref:FR:Orange"),
        str_col("ref:FR:PTT"),
        str_col("ref:FR:SFR"),
        type_col
    ],
)

table(
    "telecom_antennas",
    {"man_made": ["mast", "tower", "communications_tower"]},
    "point",
    columns=[
        str_col("ref:FR:ANFR"),
        type_col
    ],
)
