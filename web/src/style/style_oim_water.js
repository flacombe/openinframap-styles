import { text_paint, operator_text, underground_p, font } from './style_oim_common.js';

const colour_freshwater = '#7B7CBA';
const colour_wastewater = '#BAA87B';
const colour_hotwater = '#AD4C4C';
const colour_steam = '#7BBAAC';

const substance_label = ['match', ['get', 'substance'],
  "water", 'Water',
  "rainwater", "Rainwater",
  "hot_water", "Hot Water",
  "wastewater", "Wastewater",
  "sewage", "Sewage",
  "waterwaste", "Waterwaste",
  "steam", "Steam",
  ["get", "substance"]
];

const substance_colour = ["match", ["get", "substance"],
  "water", colour_freshwater,
  "rainwater", colour_freshwater,
  "hot_water", colour_hotwater,
  "wastewater", colour_wastewater,
  "sewage", colour_wastewater,
  "waterwaste", colour_wastewater,
  "steam", colour_steam,
  '#7B7CBA'
];

// Colors
const usage_scale = [
  ['transmission', '#284893'],
  ['headrace', '#347bcf'],
  ['penstock', '#82bcfc'],
  ['tailrace', '#5a7d9d'],
  ['spillway', '#954cfc'],
  [null,'#7A7A85']
]

// Predicates
const structure_color = ["case",
  ["==", ["get","tunnel"],"flooded"], "#BBBBBB",
  ["==", ["get","man_made"],"pipeline"], "#646464",
  "#AAAAAA"
]

const usage_visible_p = ["all",
  ["any",
    ["all",
      ["==", ['get', 'usage'], "transmission"],
      [">", ['zoom'], 5]
    ],
    [">", ['zoom'], 7]
  ],
  ["has","usage"],
  ["!=", ["get","usage"], null]
];
let structure_visible_p = Object.assign([], usage_visible_p);
structure_visible_p.push(["any",["==", ["get","tunnel"],"flooded"], ["==", ["get","man_made"],"pipeline"]]);

const obstacle_visible_p = ["any",
  ["all",
    ["==", ['get', 'type'], "dam"],
    [">", ['zoom'], 9]
  ],
  [">", ['zoom'], 12]
];

const pipeline_gear_radius = [
  'interpolate',
  ['linear'],
  ['zoom'],
  14,
  1,
  18, 4.5
];

const pipeline_inletoutlet_radius = [
  'interpolate',
  ['linear'],
  ['zoom'],
  13,
  1,
  16, 4
];

const intermittent_dashes_p = ["case",
["==", ["get","intermittent"],"yes"], "#BBBBBB",
"#AAAAAA"
]

// Functions
function usage_color() {
  let usage_fct = ['match', ["get", "usage"]];

  for (let row of usage_scale) {
    if (row[0] == null){
      usage_fct.push(row[1]);
      continue;
    }
    usage_fct.push(row[0]);
    usage_fct.push(row[1]);
  }

  return usage_fct;
}

// Layers
const layers = [
  {
    zorder: 300,
    id: 'water_obstacles_poly',
    type: 'fill',
    source: 'openinframap',
    'source-layer': 'water_obstacles_poly',
    filter: obstacle_visible_p,
    minzoom: 10,
    paint: {
      'fill-opacity': 0.7,
      'fill-color': "#696969",
      'fill-outline-color': "#232323",
    },
  },
  {
    zorder: 301,
    id: 'water_obstacles_line',
    type: 'line',
    source: 'openinframap',
    'source-layer': 'water_obstacles_line',
    filter: obstacle_visible_p,
    minzoom: 10,
    paint: {
      'line-color': '#232323',
      'line-opacity': 0.7,
      'line-width': 4
    },
    layout: {
      'line-join': 'round',
    }
  },
  {
    zorder: 302,
    id: 'water_bodies',
    type: 'fill',
    source: 'openinframap',
    'source-layer': 'water_bodies',
    minzoom: 7,
    paint: {
      'fill-opacity': 0.7,
      'fill-color': "#284893",
      'fill-outline-color': "#232323",
    },
  },
  {
    zorder: 310,
    id: 'water_structure',
    type: 'line',
    source: 'openinframap',
    minzoom: 8,
    'source-layer': 'water_ways',
    filter: structure_visible_p,
    paint: {
      'line-color': structure_color,
      'line-width': ['interpolate', ['linear'], ['zoom'],
        8, 1.5,
        13, 5.5
      ],
    },
    layout: {
      'line-cap': 'round',
      'line-join': 'round',
    },
  },
  {
    zorder: 311,
    id: 'water_flow',
    type: 'line',
    source: 'openinframap',
    minzoom: 3,
    'source-layer': 'water_ways',
    filter: usage_visible_p,
    paint: {
      'line-color': usage_color(),
      'line-width': ['interpolate', ['linear'], ['zoom'],
        3, 0.3,
        16, 4
      ],
    },
  },
  {
    zorder: 320,
    id: 'water_structure_gear',
    type: 'circle',
    source: 'openinframap',
    'source-layer': 'pipeline_gear',
    filter: obstacle_visible_p,
    minzoom: 15,
    paint: {
      'circle-radius': pipeline_gear_radius,
      'circle-color': '#787878',
      'circle-stroke-opacity': 1,
      'circle-stroke-color': '#424242',
      'circle-stroke-width': 1,
      'circle-opacity': 1
    }
  },
  {
    zorder: 330,
    id: 'water_flow_inlet',
    type: 'circle',
    source: 'openinframap',
    'source-layer': 'duct_inlet',
    filter: obstacle_visible_p,
    minzoom: 13,
    paint: {
      'circle-radius': pipeline_inletoutlet_radius,
      'circle-color': '#009900',
      'circle-stroke-opacity': 1,
      'circle-stroke-color': '#424242',
      'circle-stroke-width': 1,
      'circle-opacity': 1
    }
  },
  {
    zorder: 331,
    id: 'water_flow_outlet',
    type: 'circle',
    source: 'openinframap',
    'source-layer': 'duct_outlet',
    filter: obstacle_visible_p,
    minzoom: 13,
    paint: {
      'circle-radius': pipeline_inletoutlet_radius,
      'circle-color': '#DD0000',
      'circle-stroke-opacity': 1,
      'circle-stroke-color': '#424242',
      'circle-stroke-width': 1,
      'circle-opacity': 1
    }
  },
  {
    zorder: 520,
    id: 'water_flow_label',
    type: 'symbol',
    source: 'openinframap',
    'source-layer': 'water_ways',
    minzoom: 11,
    filter: usage_visible_p,
    paint: text_paint,
    layout: {
      'text-field': ["case",
        ["has", "name"], ['concat', ['get', 'name'], ' (', substance_label, ')',],
        substance_label
      ],
      'text-font': font,
      'symbol-placement': 'line',
      'symbol-spacing': 400,
      'text-size': 10,
      'text-offset': [0, 1],
      'text-max-angle': 10
    }
  },
];

export { layers as default, usage_scale, colour_freshwater, colour_wastewater, colour_hotwater, colour_steam };
