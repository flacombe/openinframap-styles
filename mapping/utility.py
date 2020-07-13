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
    "utility_support",
    {
        "man_made": ["utility_pole"],
        "construction:man_made": ["utility_pole"],
    },
    "point",
    columns=[
        type_col,
        bool_col("location:transition", "transition"),
        str_col("construction:power", "construction"),
    ],
)
