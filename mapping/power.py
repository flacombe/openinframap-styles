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
    "power_line",
    {
        "power": ["line", "minor_line", "cable"],
        "construction:power": ["line", "minor_line", "cable"],
    },
    "linestring",
    columns=[
        type_col,
        str_col("location"),
        str_col("line"),
        str_col("operator"),
        str_col("voltage"),
        str_col("frequency"),
        int_col("cables"),
        str_col("wires"),
        int_col("circuits"),
        str_col("construction:power", "construction"),
        bool_col("tunnel"),
        str_col("ref"),
    ],
)

generalized_table(
    "power_line_gen_100",
    "power_line",
    100,
    "coalesce(convert_voltage(voltage), 0) > 100000 AND ST_length(geometry) > 200 "
    "AND line NOT IN ('bay', 'busbar')",
)

generalized_table(
    "power_line_gen_500",
    "power_line",
    500,
    "coalesce(convert_voltage(voltage), 0) > 100000 AND ST_length(geometry) > 600 "
    "AND line NOT IN ('bay', 'busbar')",
)

table(
    "power_tower",
    {
        "power": ["tower", "pole", "portal", "insulator", "terminal"],
        "construction:power": ["tower", "pole", "portal", "insulator", "terminal"],
    },
    ["points", "linestrings"],
    columns=[
        type_col,
        str_col("material"),
        str_col("structure"),
        str_col("height"),
        str_col("colour"),
        str_col("operator"),
        str_col("line_attachment"),
        str_col("line_management"),
        str_col("remotely_controllable"),
        str_col("ref"),
        str_col("ref:FR:gdo"),
        str_col("ref:FR:RTE"),
        bool_col("location:transition", "transition"),
        str_col("construction:power", "construction"),
    ],
)

table(
    "power_substation",
    {
        "power": ["substation", "sub_station"],
        "construction:power": ["substation", "sub_station"],
    },
    ["points", "polygons"],
    columns=[
        type_col,
        str_col("substation"),
        str_col("location"),
        str_col("operator"),
        str_col("voltage"),
        str_col("ref"),
        str_col("ref:FR:gdo"),
        str_col("ref:FR:RTE"),
        str_col("remotely_controllable"),
        str_col("construction:power", "construction"),
    ],
)

relation_tables(
    "power_substation_relation",
    {
        "power": ["substation", "sub_station"],
        "construction:power": ["substation", "sub_station"],
    },
    relation_types=["site"],
    relation_columns=[
        str_col("substation"),
        str_col("location"),
        str_col("operator"),
        str_col("voltage"),
        str_col("ref"),
        str_col("ref:FR:gdo"),
        str_col("ref:FR:RTE"),
        str_col("remotely_controllable"),
        str_col("construction:power", "construction"),
    ],
)

table(
    "power_switchgear",
    {
        "power": [
            "switch",
            "transformer",
            "compensator",
            "converter",
        ]
    },
    ["points", "polygons"],
    columns=[
        str_col("voltage"),
        str_col("voltage:primary"),
        str_col("voltage:secondary"),
        str_col("voltage:tertiary"),
        str_col("phases"),
        str_col("frequency"),
        str_col("switch"),
        str_col("transformer"),
        str_col("ref"),
        str_col("ref:FR:gdo"),
        str_col("ref:FR:RTE"),
        type_col
    ],
)


table(
    "power_plant",
    {"power": ["plant"], "construction:power": ["plant"]},
    "polygon",
    columns=[
        str_col("plant:output:electricity", "output"),
        str_col("plant:source", "source"),
        str_col("construction_power", "construction"),
    ],
)

relation_tables(
    "power_plant_relation",
    {"power": ["plant"], "construction:power": ["plant"]},
    ["site"],
    relation_columns=[
        str_col("plant:output:electricity", "output"),
        str_col("plant:source", "source"),
        str_col("construction_power", "construction"),
    ],
)

table(
    "power_generator",
    {"power": ["generator"], "construction:power": ["generator"]},
    ["points", "polygons"],
    columns=[
        str_col("generator:source", "source"),
        str_col("generator:method", "method"),
        str_col("generator:type", "type"),
        str_col("generator:output", "output"),
        str_col("construction_power", "construction"),
        str_col("frequency"),
        str_col("voltage"),
        str_col("phases"),
        str_col("operator"),
    ],
)
