import { el, text, mount, list, setStyle } from 'redom';
import {
  default as power_layers,
  voltage_scale,
  special_voltages,
  plant_types,
} from '../style/style_oim_power.js';
import {default as comms_layers, medium_scale} from '../style/style_oim_telecoms.js';
import {
  default as petroleum_layers,
  colour_oil,
  colour_gas,
  colour_fuel,
  colour_intermediate,
  colour_hydrogen,
  colour_co2,
  colour_unknown
} from '../style/style_oim_petroleum.js';
import {
  default as water_layers,
  usage_scale,
  colour_freshwater,
  colour_wastewater,
  colour_hotwater,
  colour_steam
} from '../style/style_oim_water.js';
import {svgLine, svgRect, svgCircle, svgLineFromLayer, svgRectFromLayer, svgCircleFromLayer} from './svg.js';
import './key.css';

const line_thickness = 6;

class Td {
  constructor() {
    this.el = el('td');
  }
  update(data) {
    if (typeof data != 'object') {
      this.el.innerHTML = data;
    } else if (data === null) {
      return;
    } else {
      mount(this.el, data);
    }
  }
}

const Tr = list.extend('tr', Td);

class KeyControl {
  onAdd(map) {
    this._map = map;

    this._control = el('button', {
      class: 'maplibregl-ctrl-icon oim-key-control',
    });

    this._container = el('div', { class: 'maplibregl-ctrl oim-key-panel' });

    this.populate();

    this._control.onclick = e => {
      this._container.style.display = 'block';
      this._control.style.display = 'none';
    };

    setTimeout(e => this.resize(), 100);
    this._map.on('resize', e => this.resize());
    return el('div', this._control, this._container, {
      class: 'maplibregl-ctrl maplibregl-ctrl-group',
    });
  }

  resize() {
    // Set max-height of key depending on window style
    let map_style = window.getComputedStyle(this._map.getContainer());
    let cont_style;
    if (this._control.style.display != 'none') {
      cont_style = this._control.getBoundingClientRect();
    } else {
      cont_style = this._container.getBoundingClientRect();
    }
    let height = parseInt(map_style.height) - cont_style.top - 160 + 'px';
    setStyle(this._pane, {'max-height': height});
  }

  header() {
    const close_button = el('.oim-key-close', '×');

    close_button.onclick = e => {
      this._container.style.display = 'none';
      this._control.style.display = 'block';
    };
    return el('.oim-key-header', el('h2', 'Key'), close_button);
  }

  populate() {
    mount(this._container, this.header());

    let pane = el('.oim-key-pane');
    pane.appendChild(el('h3', 'Power Lines'));
    mount(pane, this.voltageTable());
    pane.appendChild(el('h3', 'Power Plants'));
    mount(pane, this.plantTable());
    pane.appendChild(el('h3', 'Power Generators'));
    mount(pane, this.generatorTable());
    pane.appendChild(el('h3', 'Other Power'));
    mount(pane, this.towerTable());
    pane.appendChild(el('h3', 'Telecoms'));
    mount(pane, this.telecomTable());
    pane.appendChild(el('h3', 'Petroleum'));
    mount(pane, this.petroleumTable());
    pane.appendChild(el('h3', 'Water flows'));
    mount(pane, this.waterUsageTable());
    pane.appendChild(el('h3', 'Water infrastructure'));
    mount(pane, this.waterGearTable());
    this._pane = pane;

    mount(this._container, pane);
  }

  voltageTable() {
    let rows = [];
    for (let row of voltage_scale) {
      let label = row[0];
      if (label === null) {
        label = '< 10 kV';
      } else {
        label = `≥ ${label} kV`;
      }

      rows.push([label, row[1]]);
    }

    for (const [key, value] of Object.entries(special_voltages)) {
      rows.push([key, value]);
    }

    rows = rows.map(row => [row[0], svgLine(row[1], line_thickness)]);

    rows.push(['Underground', svgLine('#7A7A85', line_thickness, '3 2')]);
    rows.push(['Line Reference', this.sprite('power_line_ref')]);

    let table = list('table', Tr);
    table.update(rows);
    return table;
  }

  sprite(name, size = 25) {
    let spriteDiv = el('img.oim-plant-sprite', {
      src: `/style/sprites/${name}.svg`,
      height: size,
    });
    setStyle(spriteDiv, {
      'max-width': size + 'px',
    });
    return spriteDiv;
  }

  plantTable() {
    let rows = [];
    for (const [key, value] of Object.entries(plant_types)) {
      rows.push([
        key.charAt(0).toUpperCase() + key.slice(1),
        this.sprite(value),
      ]);
    }
    let table = list('table', Tr);
    table.update(rows);
    return table;
  }

  generatorTable() {
    let rows = [
      ['Wind Turbine', this.sprite('power_wind', 14)],
      ['Solar Panel', svgRectFromLayer(power_layers, 'power_solar_panel')],
    ];
    let table = list('table', Tr);
    table.update(rows);
    return table;
  }

  towerTable() {
    let rows = [
      ['Tower/Pylon', this.sprite('power_tower', 10)],
      ['Transition Tower', this.sprite('power_tower_transition', 10)],
      ['Pole', this.sprite('power_pole', 8)],
      ['Transition Pole', this.sprite('power_pole_transition', 8)],
      ['Transformer', this.sprite('power_transformer')],
      ['Switch', this.sprite('power_switch')],
      ['Compensator', this.sprite('power_compensator')],
      ['Converter', this.sprite('converter')],
    ];
    let table = list('table', Tr);
    table.update(rows);
    return table;
  }

  telecomTable() {
    let rows = [];
    for (let row of medium_scale) {
      let label = row[0];

      if (label == null){
        label = "Unknown";
      }

      rows.push([label.charAt(0).toUpperCase() + label.slice(1), svgRect(row[1])]);
    }

    rows.push(['Cable', svgLineFromLayer(comms_layers, 'telecoms_line')]);
    rows.push(['Tower/Mast', this.sprite('comms_tower')]);
    rows.push(['Exchange', svgCircle("#7A7A85", 'black', 1, 8)]);
    rows.push(['Connection point', svgCircle("#7A7A85", 'black', 1, 4)]);
    rows.push(['Datacenter', svgRectFromLayer(comms_layers, 'telecoms_sites')]);

    let table = list('table', Tr);
    table.update(rows);
    return table;
  }

  petroleumTable() {
    let rows = [
      ['Oil', svgLine(colour_oil, line_thickness)],
      ['Gas', svgLine(colour_gas, line_thickness)],
      ['Petroleum Intermediate', svgLine(colour_intermediate, line_thickness)],
      ['Fuel', svgLine(colour_fuel, line_thickness)],
      ['Hydrogen', svgLine(colour_hydrogen, line_thickness)],
      ['CO<sub>2</sub>', svgLine(colour_co2, line_thickness)],
      ['Other', svgLine(colour_unknown, line_thickness)],
      [
        'Petroleum Facility',
        svgRectFromLayer(petroleum_layers, 'petroleum_site'),
      ],
    ];
    let table = list('table', Tr);
    table.update(rows);
    return table;
  }

  waterUsageTable() {
    let rows = [];
    for (let row of usage_scale) {
      let label = row[0];
      if (label == null){
        label = "Unknown";
      }

      rows.push([label.charAt(0).toUpperCase() + label.slice(1), svgLine(row[1], 4)]);
    }

    let table = list('table', Tr);
    table.update(rows);
    return table;
  }

  waterGearTable() {
    let rows = [];

    rows.push(['Reservoir', svgRectFromLayer(water_layers, 'water_bodies')]);
    rows.push(['Obstacle', svgRectFromLayer(water_layers, 'water_obstacles_poly')]);
    rows.push(['Valve', svgCircleFromLayer(water_layers, 'water_structure_gear')]);
    rows.push(['Inlet', svgCircleFromLayer(water_layers, 'water_flow_inlet')]);
    rows.push(['Outlet', svgCircleFromLayer(water_layers, 'water_flow_outlet')]);

    let table = list('table', Tr);
    table.update(rows);
    return table;
  }
}

export { KeyControl as default };
