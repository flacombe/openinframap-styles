from funcs import table, type_col, str_col

table(
    "waterway",
    {"waterway": ["canal", "pressurised"]},
    "linestring",
    columns=[
        type_col,
        str_col("name"),
        str_col("usage"),
        str_col("operator"),
        str_col("man_made"),
        str_col("tunnel"),
        str_col("bridge"),
        str_col("intermittent"),
        str_col("diameter"),
        str_col("substance")
    ],
)
