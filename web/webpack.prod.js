const path = require('path');
const webpack = require("webpack");
const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");

module.exports = merge(common, {
  output: {
    filename: 'server.js',
    path: path.resolve(__dirname, 'dist'),
  },
  mode: "production",
  module: {
    rules: [
      {
        test: /\.m?js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-env"]
          }
        }
      }
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      DEV: JSON.stringify(false)
    })
  ]
});
