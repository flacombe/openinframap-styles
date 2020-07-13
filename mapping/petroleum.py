from funcs import table, type_col, str_col

table(
    "marker",
    {"marker": ["__any__"]},
    "point",
    columns=[
        str_col("utility"),
        str_col("colour"),
        type_col
    ],
)

table(
    "pipeline",
    {"man_made": ["pipeline"], "construction:man_made": ["pipeline"]},
    "linestring",
    columns=[
        str_col("substance"),
        str_col("construction:man_made", "construction"),
    ],
)

table(
    "petroleum_site",
    {
        "industrial": [
            "oil",
            "fracking",
            "oil_storage",
            "hydrocarbons",
            "oil sands",
            "oil_sands",
            "gas",
            "natural_gas",
            "wellsite",
            "well_cluster",
        ],
        "pipeline":["substation"]
    },
    "polygon",
    columns=[
        str_col("operator"),
        str_col("utility"),
        str_col("ref"),
        type_col
    ],
)

table(
    "pipeline_gear",
    {"pipeline": ["valve", "flare", "surge_tank"]},
    "point",
    columns=[
        str_col("valve"),
        type_col
    ],
)

table(
    "petroleum_well",
    {"man_made": ["petroleum_well", "oil_well"]},
    "point",
    columns=[type_col],
)
